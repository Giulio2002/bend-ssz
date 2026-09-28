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
from light_split import unlight as _unlight   # parse modules as before their light split (codegen/light_split.py)
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _dc_module(R):
    """The codec law module (the decode facade's DC) of the readable name R."""
    s = _unlight((ROOT / 'proofs/api' / f'{R}_decode_ssz_proof_generated.bend').read_text())
    imp = dict((a, p) for p, a in re.findall(r'^import \.\./obj/(\S+) as (\w+)$', s, re.M))
    m = re.search(r'\+hchk: \{(\w+)\.CHK\(t, n\)', s)
    return ROOT / 'proofs/obj' / imp[m.group(1)]


# ---- (ii)/(iii): names with one u64 list field and fixed fields read from slots ----
# The codec law's value XV(t, k, W) has the list's value S.Sequence{VS.uitems(k, W)} at the list
# field; the object's view has UL.uview(O.Words{thaw(MM), LL}) there and evaluates to XV's fixed
# field values. vv rewrites the list field alone (e2e_ulist.uvw), the rest converts.
def ulist_view(R, X):
    src = _unlight(_dc_module(R).read_text())
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
    src = _unlight((ROOT / f'proofs/obj/{rt}.bend').read_text())
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
    src = _unlight((ROOT / 'spec/fulu_schemas.bend').read_text())
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
    enc = _unlight((dcm.parent / (dcm.stem + '_enc.bend')).read_text())
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
    rl = _unlight((ROOT / 'proofs/obj/root_types.bend').read_text()).split(f'def rep_{X}(')[1].split('\n')[1]
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
    src = _unlight(_dc_module(R).read_text())
    cm = re.search(r'^import \./(\S+) as DC$', src, re.M).group(1)
    wm = re.search(r'^import \./(\S+) as W$', src, re.M).group(1)
    wsrc = _unlight((ROOT / 'proofs/obj' / wm).read_text())
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
    enc = _unlight((dcm.parent / (dcm.stem + '_enc.bend')).read_text())
    cenc_name = re.search(r'^import \./(\S+) as E$', enc, re.M).group(1)
    cencw_name = re.search(r'^import \./(\S+) as IW$', enc, re.M).group(1)
    cenc = _unlight((ROOT / 'proofs/obj' / cenc_name).read_text())
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
    rl = _unlight((ROOT / 'proofs/obj/root_types.bend').read_text()).split(f'def rep_{X}(')[1].split('\n')[1]
    csch = []
    for k in (1, 2):
        j0 = rl.index(f'rep_{child}_bx(pj_{X}_{k - 1}(o), ') + len(f'rep_{child}_bx(pj_{X}_{k - 1}(o), ')
        j, dep = j0, 0
        while not (rl[j] == ')' and dep == 0):
            dep += {'(': 1, ')': -1}.get(rl[j], 0)
            j += 1
        csch.append(rl[j0:j])
    rlc = _unlight((ROOT / 'proofs/obj/root_types.bend').read_text()).split(f'def rep_{child}(')[1].split('\n')[1]
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


def gwin_u16list_deep_text(K):
    """lvD: lv at any tree depth, its copy bounded by the child's limit (hyB: 31 + len <= 2^K)."""
    return f'''
# the same at any tree depth (the child's copy bounded by its limit: CH0.hyB)
def lvD(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +eo: {{U32.to_nat(off) == x : Nat}},
    +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}},
    +hc: {{CH0.CHKw(t, x, off, len) == True{{}} : Bool}}) -> {{PBF.vview2(CH0.OBJw(d, t, x, off, len)) == CH0.VALw(t, x, len) : S.Value}}:
  +ec = PL.c2(len, CH0.CQ(len), CH0.eLc(t, x, off, len, hc))
  +eb = BL.bviewY(d, t, off, len, x, eo, hw, pf, VC.hyU(len, {K}n, {{==}}, CH0.hyB(len, CH0.hB(t, x, off, len, hc))))
  %Equal.sym(Nat, U32.to_nat(U32.shrn(len, 1n)), CH0.CQ(len), ec) : {{S.Sequence{{PBF.it2(_, WO.wview(O.Words{{FD.array__thaw(U32, BL.CW(d, t, off, len)), len}}))}} == CH0.VALw(t, x, len) : S.Value}}
  %Equal.sym(+List<U32>, WO.wview(O.Words{{FD.array__thaw(U32, BL.CW(d, t, off, len)), len}}), UW.WX(t, x, U32.to_nat(len)), eb) : {{S.Sequence{{PBF.it2(CH0.CQ(len), _)}} == CH0.VALw(t, x, len) : S.Value}}
  Equal.cong(S.Value, S.Value, z => S.Sequence{{z}}, PBF.it2(CH0.CQ(len), UW.WX(t, x, U32.to_nat(len))), PBM.it2(CH0.CQ(len), UW.WX(t, x, U32.to_nat(len))), PL.it2eq(CH0.CQ(len), UW.WX(t, x, U32.to_nat(len))))
'''


def vartest_view(R, X):
    src = _unlight(_dc_module(R).read_text())
    wm = re.search(r'^import \./(\S+) as W$', src, re.M).group(1)
    wsrc = _unlight((ROOT / 'proofs/obj' / wm).read_text())
    ch = re.search(r'^import \./(\S+) as CH0$', wsrc, re.M).group(1)
    x0, x6 = 'Nat.add(0n, U32.to_nat(0))', 'Nat.add(0n, U32.to_nat(6))'
    CH = f'CH0.OBJw(d, t, W.XJ0(t, 0n), W.FJ0(0, t, 0n), W.LJ0(t, 0n, n))'
    CV = 'CH0.VALw(t, W.XJ0(t, 0n), W.LJ0(t, 0n, n))'
    U16 = f'S.UnsignedValue{{P.UInt{{O.keep(2, UR.RWN(t, {x0})), 0, 0, 0, 0, 0, 0, 0}}}}'
    V16 = f'FX16.VAL(t, {x0})'
    U8 = f'FX8.VAL(t, {x6})'
    WA = 'd, t, n, 0n, 0, n, {==}, hd, hn, pf, h'
    deep = 'Nat.is_lt(d, 31n)' in src and re.search(r'^def eoJ0D\(', wsrc, re.M) is not None
    lvt = gwin_u16list_text()
    WD = 'd, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf, h'
    EL = f'lv(d, t, W.XJ0(t, 0n), W.FJ0(0, t, 0n), W.LJ0(t, 0n, n), W.eoJ0({WA}), hd, W.hwJ0({WA}), pf, W.itD0(t, 0n, 0, n, h))'
    if deep:
        # the laws at any depth: the window's facts by its D interface (hw32 = VB.u32_lt(n): the window at 0 is n)
        csrc = _unlight((ROOT / 'proofs/obj' / ch).read_text())
        K = int(re.search(r'^def hyB\(.*?VB\.pw\((\d+)n\)\) == True', csrc, re.M).group(1))
        lvt += gwin_u16list_deep_text(K)
        EL = f'lvD(d, t, W.XJ0(t, 0n), W.FJ0(0, t, 0n), W.LJ0(t, 0n, n), W.eoJ0D({WD}), W.hwJ0D({WD}), pf, W.itD0(t, 0n, 0, n, h))'
    text = f'''# ---- the view of a decoded object is the codec law's value ----
{lvt}
def vv(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, @BD@) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{{}} : Bool}}, +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}) -> {{RT.v_{X}(DC.OBJ(d, t, n)) == DC.VAL(t, n) : S.Value}}:
  +h = hchk
  +h4 = FD.nat__le_trans(Nat.add({x0}, 4n), U32.to_nat(n), A.quad(VB.pw(d)), FD.nat__le_trans(Nat.add({x0}, 4n), U32.to_nat(7), U32.to_nat(n), {{==}}, W.hFc(t, 0n, 0, n, h)), hn)
  +e16 = GW.v16w(d, t, {x0}, pf, h4)
  +el = {EL}
  Equal.trans(S.Value, S.Sequence{{S.Items{{{U16}, S.Items{{PBF.vview2({CH}), S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, S.Sequence{{S.Items{{{V16}, S.Items{{PBF.vview2({CH}), S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, DC.VAL(t, n),
    Equal.cong(U32, S.Value, z => S.Sequence{{S.Items{{S.UnsignedValue{{P.UInt{{z, 0, 0, 0, 0, 0, 0, 0}}}}, S.Items{{PBF.vview2({CH}), S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, O.keep(2, UR.RWN(t, {x0})), PBM.v16of(FX8.BX(t, {x0}), FX8.BX(t, 1n+{x0})), e16),
    Equal.cong(S.Value, S.Value, z => S.Sequence{{S.Items{{{V16}, S.Items{{z, S.Items{{{U8}, S.EmptyItems{{}}}}}}}}}}, PBF.vview2({CH}), {CV}, el))

'''
    return {'view': f'RT.v_{X}',
            'imports': ['import ../proofs/obj/root_gtypes.bend as RT', 'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/obj/packed_bytes.bend as PBF',
                        'import ../proofs/obj/pb_min.bend as PBM', 'import ../proofs/obj/vua_win.bend as UW', 'import ../proofs/obj/vua_rd.bend as UR',
                        'import ../proofs/obj/vbuf.bend as VB', 'import ../proofs/obj/vcopy.bend as VC', 'import ./e2e_blist.bend as BL', 'import ./e2e_plist.bend as PL', 'import ./e2e_gwin.bend as GW',
                        f'import ../proofs/obj/{wm} as W', f'import ../proofs/obj/{ch} as CH0',
                        'import ../proofs/obj/vfx_u16.bend as FX16', 'import ../proofs/obj/vfx_u8.bend as FX8'],
            'text': text}


VDEC_VIEWS['Gc465214E502'] = vartest_view('VarTestStruct', 'Gc465214E502')


# ---- (ii)/(iii): CompatibleUnions (codegen/var_winu's layout: a selector byte, then the arm's window) ----
# CHILD_VIEWS[arm window module] = f(obj, val, a) -> proof text of {view(obj) == val} at the arm's window
# (a = its window args x, off, len, and the helpers' context); None: they convert.
UNION_CHILD = {'var_winx_GpF350A3C486.bend': None}


def union_view(R, X):
    src = _unlight(_dc_module(R).read_text())
    wm = re.search(r'^import \./(\S+) as W$', src, re.M).group(1)
    wsrc = _unlight((ROOT / 'proofs/obj' / wm).read_text())
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
    vsrc = _unlight((ROOT / f'proofs/obj/{rt}.bend').read_text())
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
        obj = f'{ch}.OBJw(d, t, W.XJ(t, x), W.FJ(off), W.LJ(len))'
        val = f'{ch}.VALw(t, W.XJ(t, x), W.LJ(len))'
        cv = UNION_CHILD[alias_mod[ch]]
        cvp = '{==}' if cv is None else (f'{cv}(d, t, n, W.XJ(t, x), W.FJ(off), W.LJ(len), W.eoJ(d, t, n, x, off, len, eo, hd, hw, pf, h1), hd, '
                                          f'W.hwJ(d, t, n, x, off, len, eo, hd, hw, pf, h1), pf, hk)')
        GOAL = f'{{RT.v_{X}(W.OB{k}(c, W.BX(t, x), d, t, x, off, len)) == S.Selected{{W.BX(t, x), W.VV{k}(c, W.BX(t, x), t, x, len)}} : S.Value}}'
        nxt = (f'      u{k + 1}(d, t, n, x, off, len, eo, hd, hw, pf, h1, U32.is_eq(W.BX(t, x), {sels[k + 1]}), {{==}}, hk)' if k != last else
               f'      Empty.absurd({GOAL.replace("(c, ", "(False{}, ")}, FD.logic__false_true(hk))')
        L.append(f'''def u{k}(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {{U32.to_nat(off) == x : Nat}}, +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +h1: W.H1(t, x, off, len),
    +c: Bool, +ec: {{U32.is_eq(W.BX(t, x), {sel}) == c : Bool}}, +hk: {{W.K{k}(c, W.BX(t, x), t, x, off, len) == True{{}} : Bool}}) -> {GOAL}:
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
  u0(d, t, n, 0n, 0, n, {{==}}, hd, hn, pf, W.le_nat(1, n, W.hch1(t, 0n, 0, n, hchk)), U32.is_eq(W.BX(t, 0n), {sels[0]}), {{==}}, W.hchk0(t, 0n, 0, n, hchk))

'''
    chs = sorted(set(arm.values()))
    return {'view': f'RT.v_{X}',
            'imports': [f'import ../proofs/obj/{rt}.bend as RT', 'import ../proofs/obj/root_gnames.bend as RN', f'import ../proofs/obj/{wm} as W', 'import ../proofs/obj/vbuf.bend as VB', 'import ./e2e_gprog.bend as GP']
            + [f'import ../proofs/obj/{alias_mod[c]} as {c}' for c in chs],
            'text': text}


VDEC_VIEWS['GuA2212AE21F'] = union_view('CompatibleUnionA', 'GuA2212AE21F')


# ---- (iv): CompatibleUnions, from rep (DK.Or2 over the arms' pc_X_k: the arm's value v and o == X_ck{v}) ----
def vroot_union(R, X, rt='root_gtypes2', gv='gvalid_gtypes2'):
    vsrc = _unlight((ROOT / f'proofs/obj/{rt}.bend').read_text())
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
    api = _unlight((ROOT / 'proofs/api' / f'{R}_encode_ssz_proof_generated.bend').read_text())
    ci = re.search(r'^import \.\./obj/(\S+) as \w+_CI$', api, re.M).group(1)
    en = re.search(r'^import \.\./obj/(\S+) as \w+_PRV$', api, re.M).group(1)
    esrc = _unlight((ROOT / 'proofs/obj' / en).read_text())
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
    if kd in ('l', 'w'):
        return [(f't{k}', 'FD.array__Tree<U32>'), (f'N{k}', 'U32')], W(f't{k}', f'N{k}')
    if kd == 'b':
        return [(f't{k}', 'FD.array__Tree<U32>'), (f'N{k}', 'U32')], f'O.Bits{{FD.array__thaw(U32, t{k}), N{k}}}'
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
    FLD = 'ProgressiveContainer_fields' if c.get('pc') else 'Container_fields'
    SK = lambda k: 'SH.Chain_head(' + 'SH.Chain_tail(' * k + f'SH.{FLD}(Spec.{X}())' + ')' * k + ')'  # noqa: E731
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
    if any(kd == 'b' for kd, _ in fs):
        L.append(f"""# bit storage (bitlist_obj.wfb): its tree and bit count
def cpb(-w: O.Bits, +wf: BO.wfb(w)) -> {_ex(wsig, '{w == O.Bits{FD.array__thaw(U32, t), N} : O.Bits}')}:
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
        if kd == 'q':
            rp, el, arr = CPA[T]
            asig = [('t', f'FD.array__Tree<{el}>'), ('N', 'U32')]
            AL = f'{T}{{{arr.format(t="t")}, N}}'
            L.append(f"""# field {k}, a progressive list: its tree and length
def cpa{k}(-v: {T}, +s: S.Schema, +rep: RT.{rp}(v, s)) -> {_ex(asig, f'{{v == {AL} : {T}}}')}:
  (+t, +e1) = rep
  (+dw, +e2) = e1
  (+N, +e3) = e2
  (+eq, +e4) = e3
  (t, (N, eq))
""")
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
def g1(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), {uparams + ', ' if uparams else ''}+eo: {{o == {E0} : {D}}}, {cparams}) -> {G('o')}:
{chr(10).join(unp)}
  rt2(h, o, rep, {wargs}, {eqn})
""")
    lines, src = [], 'rep'
    for i, k in enumerate(us):
        lines.append(f'  (+x{k}, +r{i}) = {src}')
        src = f'r{i}'
    lines.append(f'  (+eo, +q0) = {src}')
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
        elif kd == 'w':
            args.append(f'cpw({PJ(k)}, {pn[k]})')
        elif kd == 'b':
            args.append(f'cpb({PJ(k)}, {pn[k]})')
        elif kd == 'c':
            args.append(f'cpv({PJ(k)}, {SK(k)}, {pn[k]})')
        else:
            args.append(f'cpa{k}({PJ(k)}, {SK(k)}, {pn[k]})')
    lines.append(f'  g1(h, o, rep, {"".join("x" + str(k) + ", " for k in us)}eo,\n    ' + ',\n    '.join(args) + ')')
    body = '\n'.join(lines)
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/digest.bend as D', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S',
            'import ../proofs/obj/generic_specs.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/obj/dk.bend as DK', 'import ../proofs/obj/list_obj.bend as LO',
            'import ../proofs/obj/schema_shapes.bend as SH',
            f'import ../proofs/obj/{c.get("rt", "root_gtypes")}.bend as RT', f'import ../proofs/obj/{c.get("gv", "gvalid_gtypes")}.bend as GV', 'import ./e2e_support.bend as E'] + (
            ['import ../proofs/obj/bitlist_obj.bend as BO'] if any(kd == 'b' for kd, _ in fs) else [])
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



def deep_twins(text, names, reps=(), callee_ok=None):
    """Deep twins (name + 'D') of the defs `names` of text, appended after them: hd d < 31, hw32 threaded after
    hw (the window's end below 2^32), the calls among them to the twins; reps: [(old, new)] on the twins' text."""
    import deep
    import var_win as VWN
    blocks = []
    for nm in names:
        a = text.index(f'\ndef {nm}(') + 1
        e = text.find('\n\n', a)
        blocks.append(text[a:len(text) if e < 0 else e].rstrip('\n'))
    tw = '\n\n'.join(blocks)
    tw = re.sub(r'(?<![\w.])(' + '|'.join(sorted(names, key=len, reverse=True)) + r')\(', lambda m: m.group(1) + 'D(', tw)
    tw = tw.replace('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)')
    for x_, y_ in reps:
        assert x_ in tw, x_[:80]
        tw = tw.replace(x_, y_)
    tw = deep.thread(tw, VWN.HWX, VWN.HW32X, callee_ok=callee_ok)
    assert 'Nat.is_lt(d, 28n)' not in tw
    return text.rstrip('\n') + '\n\n# ---- the same at any tree depth d < 31 (hw32: the window\'s end below 2^32) ----\n' + tw + '\n'


def gvt_deep_text():
    t = gvt_text()
    t = t.replace('import ./e2e_blist.bend as BL\n', 'import ./e2e_blist.bend as BL\nimport ../proofs/obj/vcopy.bend as VC\n', 1)
    K = int(re.search(r'^def hyB\(.*?VB\.pw\((\d+)n\)\) == True', _unlight((ROOT / 'proofs/obj/var_winx_l1024_u16.bend').read_text()), re.M).group(1))
    t = t.rstrip('\n') + '\n' + gwin_u16list_deep_text(K)
    reps = [('lv(d, t, YW.XJ0', 'lvD(d, t, YW.XJ0')]
    t2 = deep_twins(t, ['vtw', 'elv', 'v2d', 'v2b', 'v2z', 'vv2w'], reps,
                    callee_ok=lambda nm, a: (a.replace('V2.hwab(d, x, len, a, b, hab, hb, hw)', 'V2.hwab32(x, len, a, b, hab, hb, hw32)')
                                             if a.startswith('V2.hwab(') else None))
    head, tw = t2.split('# ---- the same at any tree depth d < 31', 1)
    # the window's facts by its D interface, the child's view lemma lvD (no depth bound)
    tw = re.sub(r'YW\.(eoJ0|hwJ0)\(([^()]*?), hd, hw, pf, h\)', r'YW.\1D(\2, hd, hw, hw32, pf, h)', tw)
    tw = tw.replace('), hd, YW.hwJ0D(', '), YW.hwJ0D(')
    assert tw.count(', hab, hb), eo, hd, hw),') == 1
    tw = tw.replace('V2.eoc(', 'V2.eocD(').replace(', hab, hb), eo, hd, hw),', ', hab, hb), eo, hd, hw, hw32),')
    left = [l for l in tw.split('\n') if 'V2.eoc(' in l or 'YW.eoJ0(' in l]
    assert not left, left[:2]
    return head + '# ---- the same at any tree depth d < 31' + tw


SUPPORT_OUT['e2e_gvt.bend'] = gvt_deep_text()


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
    src = _unlight(_dc_module(R).read_text())
    wm = re.search(r'^import \./(\S+) as W$', src, re.M).group(1)
    wsrc = _unlight((ROOT / 'proofs/obj' / wm).read_text())
    ch = dict((a, m) for m, a in re.findall(r'^import \./(\S+) as (CH\d+)$', wsrc, re.M))
    deep = 'Nat.is_lt(d, 31n)' in src and re.search(r'^def eoJ0D\(', wsrc, re.M) is not None
    lvt = gwin_u16list_text()
    WD = 'd, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf, h'
    if deep:
        # the laws at any depth: the window's facts by its D interface (hw32 = VB.u32_lt(n): the window at 0 is n)
        hyk = lambda m: int(re.search(r'^def hyB\(.*?VB\.pw\((\d+)n\)\) == True', _unlight((ROOT / 'proofs/obj' / m).read_text()), re.M).group(1))
        lvt += gwin_u16list_deep_text(hyk(ch['CH0']))
        EL = f'lvD(d, t, {x0_}, {f0}, {l0}, W.eoJ0D({WD}), W.hwJ0D({WD}), pf, W.itD0(t, 0n, 0, n, h))'
        EB = (f'BL.bviewY(d, t, {f1}, {l1}, {x1}, W.eoJ1D({WD}), W.hwJ1D({WD}), pf, '
              f'VC.hyU({l1}, {hyk(ch["CH1"])}n, {{==}}, CH1.hyB({l1}, CH1.hB(t, {x1}, {f1}, {l1}, W.itD1(t, 0n, 0, n, h)))))')
        EV = f'GV2.vtwD(d, t, n, {x2}, {f2}, {l2}, W.eoJ2D({WD}), hd, W.hwJ2D({WD}), W.hwJ2_32({WD}), pf, W.itD2(t, 0n, 0, n, h))'
        EW = f'GV2.vv2wD(d, t, n, {x3}, {f3}, {l3}, W.eoJ3D({WD}), hd, W.hwJ3D({WD}), W.hwJ3_32({WD}), pf, W.itD3(t, 0n, 0, n, h))'
    else:
        EL = f'lv(d, t, {x0_}, {f0}, {l0}, W.eoJ0({WA}), hd, W.hwJ0({WA}), pf, W.itD0(t, 0n, 0, n, h))'
        EB = f'BL.bview(d, t, {f1}, {l1}, {x1}, W.eoJ1({WA}), hd, W.hwJ1({WA}), pf)'
        EV = f'GV2.vtw(d, t, n, {x2}, {f2}, {l2}, W.eoJ2({WA}), hd, W.hwJ2({WA}), pf, W.itD2(t, 0n, 0, n, h))'
        EW = f'GV2.vv2w(d, t, n, {x3}, {f3}, {l3}, W.eoJ3({WA}), hd, W.hwJ3({WA}), pf, W.itD3(t, 0n, 0, n, h))'
    head = f"""# ---- the view of a decoded object is the codec law's value ----
{lvt}
# the vector of four FixedTestStructs: its view is its codec value
def fv4(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat) -> {{RT.xv_v4_GcDC3E457711(FXV4.OBJ(d, t, x)) == FXV4.VAL(t, x) : S.Value}}:
  {{==}}

def vv(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, @BD@) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{{}} : Bool}}, +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}) -> {{RT.v_{X}(DC.OBJ(d, t, n)) == DC.VAL(t, n) : S.Value}}:
  +h = hchk
  +h4 = GV2.hx4(d, 0n, n, 71, {{==}}, W.hFc(t, 0n, 0, n, h), hn)
  +e16 = GW.v16w(d, t, {X0}, pf, h4)
  +el = {EL}
  +eb = {EB}
  +ev = {EV}
  +e4 = fv4(d, t, {X15})
  +ew = {EW}
"""
    text = head + '\n'.join(steps) + '\n  {==}\n\n'
    return {'view': f'RT.v_{X}',
            'imports': ['import ../proofs/obj/root_gtypes.bend as RT', 'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/obj/packed_bytes.bend as PBF',
                        'import ../proofs/obj/pb_min.bend as PBM', 'import ../proofs/obj/vua_win.bend as UW', 'import ../proofs/obj/vua_rd.bend as UR',
                        'import ../proofs/obj/vbuf.bend as VB', 'import ./e2e_blist.bend as BL', 'import ./e2e_plist.bend as PL', 'import ./e2e_gwin.bend as GW',
                        'import ./e2e_gvt.bend as GV2', f'import ../proofs/obj/{wm} as W', f'import ../proofs/obj/{ch["CH0"]} as CH0',
                        f'import ../proofs/obj/{ch["CH1"]} as CH1', f'import ../proofs/obj/{ch["CH2"]} as CH2', 'import ../proofs/obj/vcopy.bend as VC', f'import ../proofs/obj/{ch["CH3"]} as CH3',
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
    return _unlight((ROOT / 'proofs/obj' / p).read_text())


ENCR_LISTS = {  # tag: (encode record module, window module, kind)
    'l1024': ('big_encx_l1024_u16.bend', 'var_winx_l1024_u16.bend', 'u16'),
    'l128': ('big_encx_l128_u16.bend', 'var_winx_l128_u16.bend', 'u16'),
    'b256': ('big_encx_bl256.bend', 'big_vvlb_bl256.bend', 'bytes'),
    'l123': ('big_encx_l123_u16.bend', 'var_winx_l123_u16.bend', 'u16'),
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


# ==== e2e_gpb: a progressive bit list read at a byte window: its root view is its codec value ====
def gpb_text():
    TR = 'FD.array__Tree<U32>'
    WP = ('+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},\n'
          '    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')
    M = 'UCT.CT(d, t, off, len, VLS.DZ(len))'
    CLR = lambda n: f'BK.btk(U32.to_nat(NB), BK.bitsof(FD.array__slots(U32, FD.array__freeze(U32, O.clear_bit(FD.array__thaw(U32, M), NB)))))'  # noqa: E731
    GOALC = '{BK.btk(U32.to_nat(NB), BK.bitsof(FD.array__slots(U32, FD.array__freeze(U32, O.clear_bit(FD.array__thaw(U32, M), NB))))) == BK.btk(U32.to_nat(NB), BK.bitsof(FD.array__slots(U32, M))) : +List<Bool>}'
    CP = ('+dz: Nat, +M: FD.array__Tree<U32>, +NB: U32, +m: Nat, +h: Nat, +pf: {FD.array__perfect(U32, dz, M) == True{} : Bool}, +hdz: {Nat.is_lt(dz, 32n) == True{} : Bool}, '
          '+hh: {Nat.is_le(h, 7n) == True{} : Bool}, +eNB: {U32.to_nat(NB) == Nat.add(VSP.x8(m), h) : Nat}')
    cases = []
    # n = U32{b0, b1, r}: its low bits give m = n - 1 = j + 4 K and the delimiter NB = 32 K + (8 j + h)
    for (b0, b1, j, nwr) in [('True{}', 'False{}', 0, 'BV.nwr1'), ('False{}', 'True{}', 1, 'BV.nwr2'), ('True{}', 'True{}', 2, 'BV.nwr3')]:
        U = f'U32{{WCon{{{b0}, WCon{{{b1}, r}}}}}}'
        K = 'Word.to_nat(30n, r)'
        cases.append((b0, b1, f'''def pc{j + 1}(+r: Word(30n), {CP}, +hN: {{Nat.is_le(C.nwn(U32.to_nat({U})), FD.spec_common__pow2(dz)) == True{{}} : Bool}}, +e1: {{U32.to_nat({U}) == 1n+m : Nat}})
    -> {GOALC}:
  +em = FD.nat__succ_inj(m, Nat.add({j}n, A.quad({K})), Equal.sym(Nat, U32.to_nat({U}), 1n+m, e1))
  +eNB2 = Equal.trans(Nat, U32.to_nat(NB), Nat.add(VSP.x8(m), h), Nat.add(BV.x32({K}), Nat.add({8 * j}n, h)), eNB,
    Equal.trans(Nat, Nat.add(VSP.x8(m), h), Nat.add(Nat.add({8 * j}n, BV.x32({K})), h), Nat.add(BV.x32({K}), Nat.add({8 * j}n, h)),
      Equal.cong(Nat, Nat, z => Nat.add(z, h), VSP.x8(m), Nat.add({8 * j}n, BV.x32({K})),
        Equal.trans(Nat, VSP.x8(m), VSP.x8(Nat.add({j}n, A.quad({K}))), Nat.add({8 * j}n, BV.x32({K})), Equal.cong(Nat, Nat, z => VSP.x8(z), m, Nat.add({j}n, A.quad({K})), em),
          Equal.cong(Nat, Nat, z => Nat.add({8 * j}n, z), VSP.x8(A.quad({K})), BV.x32({K}), BV.x8q({K})))),
      BV.alg3({8 * j}n, BV.x32({K}), h)))
  +hq = FD.nat__succ_le_lt({K}, FD.spec_common__pow2(dz), FD.logic__subst(Nat, z => {{Nat.is_le(z, FD.spec_common__pow2(dz)) == True{{}} : Bool}}, C.nwn(U32.to_nat({U})), 1n+{K}, {nwr}({K}), hN))
  pq(dz, M, NB, {K}, Nat.add({8 * j}n, h), pf, hdz, FD.nat__le_lt_trans(Nat.add({8 * j}n, h), {8 * j + 7}n, 32n, Order.add_left({8 * j}n, h, 7n, hh), {{==}}), eNB2, hq)
'''))
    U0 = 'U32{WCon{False{}, WCon{False{}, r}}}'
    pc0 = f'''def pc0(+r: Word(30n), +Qn: Nat, +eq: {{Word.to_nat(30n, r) == Qn : Nat}}, {CP}, +hN: {{Nat.is_le(C.nwn(U32.to_nat({U0})), FD.spec_common__pow2(dz)) == True{{}} : Bool}},
    +e1: {{U32.to_nat({U0}) == 1n+m : Nat}}) -> {GOALC}:
  match Qn:
    case 0n: Empty.absurd({GOALC}, FD.nat__succ_zero(m, Equal.sym(Nat, 0n, 1n+m, FD.logic__subst(Nat, z => {{A.quad(z) == 1n+m : Nat}}, Word.to_nat(30n, r), 0n, eq, e1))))
    case 1n+ +Q:
      +em = FD.nat__succ_inj(m, Nat.add(3n, A.quad(Q)), Equal.sym(Nat, A.quad(1n+Q), 1n+m, FD.logic__subst(Nat, z => {{A.quad(z) == 1n+m : Nat}}, Word.to_nat(30n, r), 1n+Q, eq, e1)))
      +eNB2 = Equal.trans(Nat, U32.to_nat(NB), Nat.add(VSP.x8(m), h), Nat.add(BV.x32(Q), Nat.add(24n, h)), eNB,
        Equal.trans(Nat, Nat.add(VSP.x8(m), h), Nat.add(Nat.add(24n, BV.x32(Q)), h), Nat.add(BV.x32(Q), Nat.add(24n, h)),
          Equal.cong(Nat, Nat, z => Nat.add(z, h), VSP.x8(m), Nat.add(24n, BV.x32(Q)),
            Equal.trans(Nat, VSP.x8(m), VSP.x8(Nat.add(3n, A.quad(Q))), Nat.add(24n, BV.x32(Q)), Equal.cong(Nat, Nat, z => VSP.x8(z), m, Nat.add(3n, A.quad(Q)), em),
              Equal.cong(Nat, Nat, z => Nat.add(24n, z), VSP.x8(A.quad(Q)), BV.x32(Q), BV.x8q(Q)))),
          BV.alg3(24n, BV.x32(Q), h)))
      +hq = FD.nat__succ_le_lt(Q, FD.spec_common__pow2(dz), FD.logic__subst(Nat, z => {{Nat.is_le(z, FD.spec_common__pow2(dz)) == True{{}} : Bool}}, C.nwn(U32.to_nat({U0})), 1n+Q,
        Equal.trans(Nat, C.nwn(U32.to_nat({U0})), Word.to_nat(30n, r), 1n+Q, C.rq(Word.to_nat(30n, r)), eq), hN))
      pq(dz, M, NB, Q, Nat.add(24n, h), pf, hdz, FD.nat__le_lt_trans(Nat.add(24n, h), 31n, 32n, Order.add_left(24n, h, 7n, hh), {{==}}), eNB2, hq)
'''
    return f'''import Base
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/nat_order.bend as Order
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vbig.bend as VBG
import ../proofs/obj/vspec.bend as VSP
import ../proofs/obj/spec_fixed.bend as SF
import ../proofs/obj/words_obj.bend as WO
import ../proofs/obj/vcopy.bend as VC
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/vbyte.bend as VY
import ../proofs/obj/vbytes.bend as VBY
import ../proofs/obj/vua_copy.bend as UC
import ../proofs/obj/vua_ct.bend as UCT
import ../proofs/obj/vua_win.bend as UW
import ../proofs/obj/vlist.bend as VLS
import ../proofs/obj/vbitl.bend as VBL
import ../proofs/obj/vbrt.bend as VR
import ../proofs/obj/vu32.bend as VU
import ../proofs/obj/vpb29.bend as VP
import ../proofs/obj/bitlist_obj.bend as BO
import ../proofs/obj/bitlist_pack.bend as BK
import ../proofs/obj/big_var_winp_pbits.bend as PBW
import ./e2e_cap.bend as C
import ./e2e_blist.bend as BL
import ./e2e_bview.bend as BV

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# A progressive bit list read at a byte window (x, off, len): the decoder copies the window's words
# (UCT.CT at depth DZ(len)) and clears the delimiter bit NB = 8 (len - 1) + h (no mask); its root view
# (the first NB bits) is the value bits of the window's bytes (pbv).

# the copy is a perfect tree
def ctp(+r: Nat, +d: Nat, +t: {TR}, +off: U32, +L: U32, +dz: Nat) -> {{FD.array__perfect(U32, dz, UCT.cts(r, d, t, off, L, dz)) == True{{}} : Bool}}:
  match r:
    case 0n: VBY.mk_perfect(L, dz, VB.mone(VC.NW(L), VR.QX(off), 0n, dz, VC.ZT(dz), t), VB.mone_perfect(VC.NW(L), VR.QX(off), 0n, dz, VC.ZT(dz), t, FD.array__trep_perfect(U32, dz, 0)))
    case 1n+ +q: VBY.mk_perfect(L, dz, UC.smone(1n+q, VC.NW(L), VR.QX(off), 0n, dz, d, VC.ZT(dz), t), UC.smone_perfect(1n+q, VC.NW(L), VR.QX(off), 0n, dz, d, VC.ZT(dz), t, FD.array__trep_perfect(U32, dz, 0)))

# ---- the delimiter bit NB as a Nat ----
def x8pw(+k: Nat) -> {{VSP.x8(VB.pw(k)) == VB.pw(3n+k) : Nat}}:
  Equal.trans(Nat, VSP.x8(VB.pw(k)), Nat.mul(VB.pw(k), 8n), VB.pw(3n+k), Equal.sym(Nat, Nat.mul(VB.pw(k), 8n), VSP.x8(VB.pw(k)), VC.x8_mul(VB.pw(k))), VBG.mul8(VB.pw(k)))

def x8lt(+m: Nat, +k: Nat, +h: {{Nat.is_lt(m, VB.pw(k)) == True{{}} : Bool}}) -> {{Nat.is_le(Nat.add(8n, VSP.x8(m)), VB.pw(3n+k)) == True{{}} : Bool}}:
  FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(8n, VSP.x8(m)), z) == True{{}} : Bool}}, VSP.x8(VB.pw(k)), VB.pw(3n+k), x8pw(k),
    VSP.x8_mono(1n+m, VB.pw(k), FD.nat__lt_succ_le_succ(m, VB.pw(k), h)))

def nb(+t: {TR}, +off: U32, +len: U32, +m: Nat, +e1: {{U32.to_nat(len) == 1n+m : Nat}}, +h29: {{U32.is_lt(U32.sub(len, 1), 536870912) == True{{}} : Bool}})
    -> {{U32.to_nat(PBW.NB(t, off, len)) == Nat.add(VSP.x8(m), VY.hb(PBW.V(t, off, len))) : Nat}}:
  +em = VP.em1(len, m, e1)
  +hb29 = Equal.trans(Bool, Nat.is_lt(U32.to_nat(U32.sub(len, 1)), FD.spec_common__pow2(29n)), U32.is_lt(U32.sub(len, 1), FD.u32__pow2u(29n)), True{{}},
    FD.array__lt_bridge(U32.sub(len, 1), 29n, {{==}}, U32.is_lt(U32.sub(len, 1), FD.u32__pow2u(29n)), {{==}}), h29)
  +hm = FD.logic__subst(Nat, z => {{Nat.is_lt(z, FD.spec_common__pow2(29n)) == True{{}} : Bool}}, U32.to_nat(U32.sub(len, 1)), m, em, hb29)
  +h8 = x8lt(m, 29n, hm)
  +h7 = FD.nat__lt_le_trans(Nat.add(7n, VSP.x8(m)), Nat.add(8n, VSP.x8(m)), FD.spec_common__pow2(32n), FD.nat__lt_succ(Nat.add(7n, VSP.x8(m))), h8)
  +hx = FD.nat__le_lt_trans(VSP.x8(m), Nat.add(7n, VSP.x8(m)), FD.spec_common__pow2(32n), Order.left_below_sum(7n, VSP.x8(m)) , h7)
  +eX = FD.u32__to_nat_from_nat(VSP.x8(m), 32n, {{==}}, hx)
  +hP = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.mul(8n, z), U32.to_nat(U32.from_nat(VSP.x8(m)))) == True{{}} : Bool}}, m, U32.to_nat(U32.sub(len, 1)), Equal.sym(Nat, U32.to_nat(U32.sub(len, 1)), m, em),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(U32.from_nat(VSP.x8(m)))) == True{{}} : Bool}}, VSP.x8(m), Nat.mul(8n, m), Equal.sym(Nat, Nat.mul(8n, m), VSP.x8(m), VR.mul8(m)),
      FD.logic__subst(Nat, z => {{Nat.is_le(VSP.x8(m), z) == True{{}} : Bool}}, VSP.x8(m), U32.to_nat(U32.from_nat(VSP.x8(m))), Equal.sym(Nat, U32.to_nat(U32.from_nat(VSP.x8(m))), VSP.x8(m), eX), FD.nat__le_refl(VSP.x8(m)))))
  +emul = Equal.trans(Nat, U32.to_nat(U32.mul(8, U32.sub(len, 1))), Nat.mul(8n, U32.to_nat(U32.sub(len, 1))), VSP.x8(m), VU.mul_le(8, U32.sub(len, 1), U32.from_nat(VSP.x8(m)), hP),
    Equal.trans(Nat, Nat.mul(8n, U32.to_nat(U32.sub(len, 1))), Nat.mul(8n, m), VSP.x8(m), Equal.cong(Nat, Nat, z => Nat.mul(8n, z), U32.to_nat(U32.sub(len, 1)), m, em), VR.mul8(m)))
  +hv = FD.nat__le_lt_trans(Nat.add(U32.to_nat(O.high_bit(PBW.V(t, off, len))), VSP.x8(m)), Nat.add(7n, VSP.x8(m)), FD.spec_common__pow2(32n),
    Order.add_right(U32.to_nat(O.high_bit(PBW.V(t, off, len))), 7n, VSP.x8(m), BV.hb7(PBW.V(t, off, len))), h7)
  Equal.trans(Nat, U32.to_nat(PBW.NB(t, off, len)), Nat.add(U32.to_nat(O.high_bit(PBW.V(t, off, len))), VSP.x8(m)), Nat.add(VSP.x8(m), VY.hb(PBW.V(t, off, len))),
    VB.add_lt32(U32.mul(8, U32.sub(len, 1)), O.high_bit(PBW.V(t, off, len)), VSP.x8(m), emul, hv), FD.nat__add_comm(U32.to_nat(O.high_bit(PBW.V(t, off, len))), VSP.x8(m)))

# ---- clearing the delimiter keeps the first NB bits (BV.clr), by the low bits of n ----
def pq(+dz: Nat, +M: {TR}, +NB: U32, +Q: Nat, +p: Nat, +pf: {{FD.array__perfect(U32, dz, M) == True{{}} : Bool}}, +hdz: {{Nat.is_lt(dz, 32n) == True{{}} : Bool}},
    +hp: {{Nat.is_lt(p, 32n) == True{{}} : Bool}}, +eNB: {{U32.to_nat(NB) == Nat.add(BV.x32(Q), p) : Nat}}, +hq: {{Nat.is_lt(Q, FD.spec_common__pow2(dz)) == True{{}} : Bool}}) -> {GOALC}:
  +e5 = Equal.trans(Nat, U32.to_nat(U32.shrn(NB, 5n)), VD.s_rng(5n, U32.to_nat(NB)), Q, VD.shrk(5n, NB),
    Equal.trans(Nat, VD.s_rng(5n, U32.to_nat(NB)), VD.s_rng(5n, Nat.add(BV.x32(Q), p)), Q, Equal.cong(Nat, Nat, z => VD.s_rng(5n, z), U32.to_nat(NB), Nat.add(BV.x32(Q), p), eNB), BV.s5q(Q, p, hp)))
  BV.clr(dz, M, NB, pf, hdz, FD.logic__subst(Nat, z => {{Nat.is_lt(z, FD.spec_common__pow2(dz)) == True{{}} : Bool}}, Q, U32.to_nat(U32.shrn(NB, 5n)), Equal.sym(Nat, U32.to_nat(U32.shrn(NB, 5n)), Q, e5), hq))

{pc0}
{cases[0][2]}
{cases[1][2]}
{cases[2][2]}
def pobj(+n: U32, {CP}, +hN: {{Nat.is_le(C.nwn(U32.to_nat(n)), FD.spec_common__pow2(dz)) == True{{}} : Bool}}, +e1: {{U32.to_nat(n) == 1n+m : Nat}}) -> {GOALC}:
  match n:
    case U32{{WCon{{False{{}}, WCon{{False{{}}, +r}}}}}}: pc0(r, Word.to_nat(30n, r), {{==}}, dz, M, NB, m, h, pf, hdz, hh, eNB, hN, e1)
    case U32{{WCon{{True{{}}, WCon{{False{{}}, +r}}}}}}: pc1(r, dz, M, NB, m, h, pf, hdz, hh, eNB, hN, e1)
    case U32{{WCon{{False{{}}, WCon{{True{{}}, +r}}}}}}: pc2(r, dz, M, NB, m, h, pf, hdz, hh, eNB, hN, e1)
    case U32{{WCon{{True{{}}, WCon{{True{{}}, +r}}}}}}: pc3(r, dz, M, NB, m, h, pf, hdz, hh, eNB, hN, e1)

# ---- the view, at any copy of the window's bytes: M a perfect tree of depth DZ(len) whose first len bytes
# are the window's (ewl), the window's length (hlv) and last byte (lw) ----
def pbc(+t: {TR}, +x: Nat, +off: U32, +len: U32, +M: {TR}, +pfM: {{FD.array__perfect(U32, VLS.DZ(len), M) == True{{}} : Bool}}, +m: Nat,
    +e1: {{U32.to_nat(len) == 1n+m : Nat}}, +h29: {{U32.is_lt(U32.sub(len, 1), 536870912) == True{{}} : Bool}},
    +ewl: {{VSP.bt(U32.to_nat(len), SF.limbs(FD.array__slots(U32, M))) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}},
    +hlv: {{List.length(&2, U32, UW.WX(t, x, 1n+m)) == 1n+m : Nat}}, +lw: {{VBL.lastb(UW.WX(t, x, 1n+m)) == PBW.V(t, off, len) : U32}})
    -> {{BK.btk(U32.to_nat(PBW.NB(t, off, len)), BK.bitsof(FD.array__slots(U32, FD.array__freeze(U32, O.clear_bit(FD.array__thaw(U32, M), PBW.NB(t, off, len)))))) == VBL.bl(UW.WX(t, x, U32.to_nat(len))) : +List<Bool>}}:
  +V = PBW.V(t, off, len)
  +h = VY.hb(V)
  +dz = VLS.DZ(len)
  +hdz = FD.nat__le_lt_trans(dz, 29n, 32n, VP.hdzP(len, m, e1, h29), {{==}})
  +eNB = nb(t, off, len, m, e1, h29)
  +hL = VP.le29(len, m, e1, h29)
  +hNW = C.nw(len, 27n, {{==}}, hL)
  +hN = FD.logic__subst(Nat, z => {{Nat.is_le(z, FD.spec_common__pow2(dz)) == True{{}} : Bool}}, Nat.add(VC.NW(len), 0n), C.nwn(U32.to_nat(len)),
    Equal.trans(Nat, Nat.add(VC.NW(len), 0n), VC.NW(len), C.nwn(U32.to_nat(len)), FD.nat__add_zero(VC.NW(len)), hNW), VP.hrgP(len, m, e1, h29))
  +A1 = pobj(len, dz, M, PBW.NB(t, off, len), m, h, pfM, hdz, BV.hb7(V), eNB, hN, e1)
  +W1 = UW.WX(t, x, 1n+m)
  +ew = FD.logic__subst(Nat, z => {{VSP.bt(z, SF.limbs(FD.array__slots(U32, M))) == UW.WX(t, x, z) : +List<U32>}}, U32.to_nat(len), 1n+m, e1, ewl)
  +hlM = VR.lenS(dz, M, pfM)
  +hq4 = FD.nat__le_trans(1n+m, A.quad(C.nwn(U32.to_nat(len))), A.quad(VB.pw(dz)),
    FD.logic__subst(Nat, z => {{Nat.is_le(z, A.quad(C.nwn(U32.to_nat(len)))) == True{{}} : Bool}}, U32.to_nat(len), 1n+m, e1, C.ng(U32.to_nat(len))), C.q4(C.nwn(U32.to_nat(len)), VB.pw(dz), hN))
  +hl = FD.logic__subst(Nat, z => {{Nat.is_lt(m, z) == True{{}} : Bool}}, A.quad(VB.pw(dz)), List.length(&2, U32, SF.limbs(FD.array__slots(U32, M))), Equal.sym(Nat, List.length(&2, U32, SF.limbs(FD.array__slots(U32, M))), A.quad(VB.pw(dz)), hlM),
    FD.nat__succ_le_lt(m, A.quad(VB.pw(dz)), hq4))
  +eh = Equal.cong(U32, Nat, z => VY.hb(z), VBL.lastb(W1), V, lw)
  +B1 = BV.vbits(M, m, h, W1, BV.hb7(V), ew, hl, hlv, eh)
  %Equal.sym(Nat, U32.to_nat(len), 1n+m, e1) : {{BK.btk(U32.to_nat(PBW.NB(t, off, len)), BK.bitsof(FD.array__slots(U32, FD.array__freeze(U32, O.clear_bit(FD.array__thaw(U32, M), PBW.NB(t, off, len)))))) == VBL.bl(UW.WX(t, x, _)) : +List<Bool>}}
  %Equal.sym(Nat, U32.to_nat(PBW.NB(t, off, len)), Nat.add(VSP.x8(m), h), eNB) : {{BK.btk(_, BK.bitsof(FD.array__slots(U32, FD.array__freeze(U32, O.clear_bit(FD.array__thaw(U32, M), PBW.NB(t, off, len)))))) == VBL.bl(W1) : +List<Bool>}}
  Equal.trans(+List<Bool>, BK.btk(Nat.add(VSP.x8(m), h), BK.bitsof(FD.array__slots(U32, FD.array__freeze(U32, O.clear_bit(FD.array__thaw(U32, M), PBW.NB(t, off, len)))))), BK.btk(Nat.add(VSP.x8(m), h), BK.bitsof(FD.array__slots(U32, M))), VBL.bl(W1),
    FD.logic__subst(Nat, z => {{BK.btk(z, BK.bitsof(FD.array__slots(U32, FD.array__freeze(U32, O.clear_bit(FD.array__thaw(U32, M), PBW.NB(t, off, len)))))) == BK.btk(z, BK.bitsof(FD.array__slots(U32, M))) : +List<Bool>}}, U32.to_nat(PBW.NB(t, off, len)), Nat.add(VSP.x8(m), h), eNB, A1),
    B1)

# the view of the window's copy (d < 28): the check gives len = 1 + m and len - 1 < 2^29
def pbv({WP}, +hchk: {{PBW.CHKw(t, x, off, len) == True{{}} : Bool}}) -> {{BO.bview(PBW.OBJw(d, t, x, off, len)) == VBL.bl(UW.WX(t, x, U32.to_nat(len))) : +List<Bool>}}:
  +e1 = PBW.cE(t, x, off, len, hchk)
  +m = PBW.M1(len)
  +h1 = PBW.c1(t, x, off, len, hchk)
  +nz = PBW.cB(t, off, len, h1)
  +h29 = FD.logic__subst(Bool, z => {{O.bsel(z, False{{}}, O.bsel(True{{}}, U32.is_lt(U32.sub(len, 1), 536870912), Nat.is_le(PBW.BD(t, off, len), U32.to_nat(0)))) == True{{}} : Bool}},
    U32.is_eq(PBW.V(t, off, len), 0), False{{}}, nz, h1)
  +M = {M}
  +hw1 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == True{{}} : Bool}}, U32.to_nat(len), 1n+m, e1, hw)
  +ewl = Equal.trans(+List<U32>, VSP.bt(U32.to_nat(len), SF.limbs(FD.array__slots(U32, M))), WO.wview(O.Words{{FD.array__thaw(U32, M), len}}), UW.WX(t, x, U32.to_nat(len)),
    Equal.sym(+List<U32>, WO.wview(O.Words{{FD.array__thaw(U32, M), len}}), VSP.bt(U32.to_nat(len), SF.limbs(FD.array__slots(U32, M))), BL.wvb(M, len)), BL.bview(d, t, off, len, x, eo, hd, hw, pf))
  pbc(t, x, off, len, M, ctp(VR.RX(off), d, t, off, len, VLS.DZ(len)), m, e1, h29, ewl, UW.lenWX(d, t, x, 1n+m, pf, hw1),
    UW.lastWX(d, t, x, m, VR.XN(off, len), pf, hw1, PBW.eX(d, x, off, len, eo, hd, hw, e1)))
'''


SUPPORT_OUT['e2e_gpb.bend'] = gpb_text()


# ==== e2e_gprog: the progressive containers read at a byte window: root view == codec value (vw_X) ====
GP_WA = 'd, t, n, x, off, len, eo, hd, hw, pf, h'
GP_WP = ('+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},\n'
         '    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')


def gp_lv(tag, CH):
    """lv_<tag>: a List[uint16, N] child (window module CH) read at a byte window: root view == codec value."""
    return f'''def lv_{tag}(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +eo: {{U32.to_nat(off) == x : Nat}}, +hd: {{Nat.is_lt(d, 28n) == True{{}} : Bool}},
    +hw: {{Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{{}} : Bool}}, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}},
    +hc: {{{CH}.CHKw(t, x, off, len) == True{{}} : Bool}}) -> {{PBF.vview2({CH}.OBJw(d, t, x, off, len)) == {CH}.VALw(t, x, len) : S.Value}}:
  +ec = PL.c2(len, {CH}.CQ(len), {CH}.eLc(t, x, off, len, hc))
  +eb = BL.bview(d, t, off, len, x, eo, hd, hw, pf)
  %Equal.sym(Nat, U32.to_nat(U32.shrn(len, 1n)), {CH}.CQ(len), ec) : {{S.Sequence{{PBF.it2(_, WO.wview(O.Words{{FD.array__thaw(U32, BL.CW(d, t, off, len)), len}}))}} == {CH}.VALw(t, x, len) : S.Value}}
  %Equal.sym(+List<U32>, WO.wview(O.Words{{FD.array__thaw(U32, BL.CW(d, t, off, len)), len}}), UW.WX(t, x, U32.to_nat(len)), eb) : {{S.Sequence{{PBF.it2({CH}.CQ(len), _)}} == {CH}.VALw(t, x, len) : S.Value}}
  Equal.cong(S.Value, S.Value, z => S.Sequence{{z}}, PBF.it2({CH}.CQ(len), UW.WX(t, x, U32.to_nat(len))), PBM.it2({CH}.CQ(len), UW.WX(t, x, U32.to_nat(len))), PL.it2eq({CH}.CQ(len), UW.WX(t, x, U32.to_nat(len))))
'''


def _gp_seq(items):
    out = 'S.EmptyItems{}'
    for it in reversed(items):
        out = f'S.Items{{{it}, {out}}}'
    return f'S.Sequence{{{out}}}'


def gp_view(X, W, fields):
    """vw_X: fields [(lhs item of the object's view, rhs item of VALw, proof of lhs == rhs or None when they convert)]."""
    lets, steps = [], []
    lhs = [f[0] for f in fields]
    rhs = [f[1] for f in fields]
    for i, (_, _, pr) in enumerate(fields):
        if pr is None:
            continue
        lets.append(f'  +e{i} = {pr}')
    idx = [i for i, f in enumerate(fields) if f[2] is not None]
    for i in idx:
        it = [lhs[q] if (q < i or fields[q][2] is None) else ('_' if q == i else rhs[q]) for q in range(len(fields))]
        steps.append(f'  %e{i} : {{RT2.v_{X}({W}.OBJw(d, t, x, off, len)) == {_gp_seq(it)} : S.Value}}')
    return (f'def vw_{X}({GP_WP}, +h: {{{W}.CHKw(t, x, off, len) == True{{}} : Bool}})\n'
            f'    -> {{RT2.v_{X}({W}.OBJw(d, t, x, off, len)) == {W}.VALw(t, x, len) : S.Value}}:\n' + '\n'.join(lets + steps) + '\n  {==}\n')


GP_PL = r"""# ---- a progressive list of uint8 at a byte window ----
def pu8(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hc: {PU8.CHKw(t, x, off, len) == True{} : Bool}) -> {PBF.vview1(PU8.OBJw(d, t, x, off, len)) == PU8.VALw(t, x, len) : S.Value}:
  +eb = BL.bview(d, t, off, len, x, eo, hd, hw, pf)
  %Equal.sym(+List<U32>, WO.wview(O.Words{FD.array__thaw(U32, BL.CW(d, t, off, len)), len}), UW.WX(t, x, U32.to_nat(len)), eb) : {S.Sequence{PBF.it1(U32.to_nat(len), _)} == PU8.VALw(t, x, len) : S.Value}
  Equal.cong(S.Value, S.Value, z => S.Sequence{z}, PBF.it1(U32.to_nat(len), UW.WX(t, x, U32.to_nat(len))), PBM.it1(U32.to_nat(len), UW.WX(t, x, U32.to_nat(len))), PL.it1eq(U32.to_nat(len), UW.WX(t, x, U32.to_nat(len))))

# ---- a progressive list of uint64 at a byte window: its first 2 c words are the window's ----
# the two uitems (ulist_obj, vspec) agree
def uu(+k: Nat, +W: List<&2, U32>) -> {UL.uitems(k, W) == VS.uitems(k, W) : S.Value}:
  match k W:
    case 0n _: {==}
    case 1n+ +c Nil{}: {==}
    case 1n+ +c Con{+a, Nil{}}: {==}
    case 1n+ +c Con{+a, Con{+b, +rest}}: Equal.cong(S.Value, S.Value, z => S.Items{S.UnsignedValue{P.UInt{a, b, 0, 0, 0, 0, 0, 0}}, z}, UL.uitems(c, rest), VS.uitems(c, rest), uu(c, rest))
# ... and read only the first 2 k words
def ut(+k: Nat, +W: List<&2, U32>) -> {VS.uitems(k, W) == VS.uitems(k, VS.wtake(Nat.double(k), W)) : S.Value}:
  match k W:
    case 0n _: {==}
    case 1n+ +c Nil{}: {==}
    case 1n+ +c Con{+a, Nil{}}: {==}
    case 1n+ +c Con{+a, Con{+b, +rest}}: Equal.cong(S.Value, S.Value, z => S.Items{S.UnsignedValue{P.UInt{a, b, 0, 0, 0, 0, 0, 0}}, z}, VS.uitems(c, rest), VS.uitems(c, VS.wtake(Nat.double(c), rest)), ut(c, rest))
def xb2(+c: Nat) -> {VS.x8(c) == EL.b2(c) : Nat}:
  match c:
    case 0n: {==}
    case 1n+ +q: Equal.cong(Nat, Nat, z => 8n+z, VS.x8(q), EL.b2(q), xb2(q))

def pu64(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hc: {PU64.CHKw(t, x, off, len) == True{} : Bool}) -> {UL.uview(PU64.OBJw(d, t, x, off, len)) == PU64.VALw(t, x, len) : S.Value}:
  +c = PU64.CQ(len)
  +M = UCT.CT(d, t, off, len, VLS.DZ(len))
  +el = PU64.eLc(t, x, off, len, hc)
  +ec = Equal.trans(Nat, U32.to_nat(U32.shrn(len, 3n)), VD.s_rng(3n, U32.to_nat(len)), c, VD.shrk(3n, len),
    Equal.trans(Nat, VD.s_rng(3n, U32.to_nat(len)), VD.s_rng(3n, EL.b2(c)), c,
      Equal.cong(Nat, Nat, z => VD.s_rng(3n, z), U32.to_nat(len), EL.b2(c), Equal.trans(Nat, U32.to_nat(len), VS.x8(c), EL.b2(c), el, xb2(c))), PW.rb2(c)))
  +hL = FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw)
  +eL = Equal.trans(Nat, U32.to_nat(len), VS.x8(c), A.quad(Nat.double(c)), el, Equal.trans(Nat, VS.x8(c), Nat.mul(c, 8n), A.quad(Nat.double(c)), Equal.sym(Nat, Nat.mul(c, 8n), VS.x8(c), VC.x8_mul(c)), VBG.mul8(c)))
  +ew = BXW.ctw(d, t, off, len, VLS.DZ(len), x, Nat.double(c), eo, hd, hw, pf, VLS.hrg(d, len, hd, hL), eL)
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, M)), M, FD.array__freeze_thaw(U32, M)) :
    {S.Sequence{UL.uitems(U32.to_nat(U32.shrn(len, 3n)), FD.array__slots(U32, _))} == PU64.VALw(t, x, len) : S.Value}
  %Equal.sym(Nat, U32.to_nat(U32.shrn(len, 3n)), c, ec) : {S.Sequence{UL.uitems(_, FD.array__slots(U32, M))} == PU64.VALw(t, x, len) : S.Value}
  %Equal.sym(S.Value, UL.uitems(c, FD.array__slots(U32, M)), VS.uitems(c, FD.array__slots(U32, M)), uu(c, FD.array__slots(U32, M))) : {S.Sequence{_} == PU64.VALw(t, x, len) : S.Value}
  %Equal.sym(S.Value, VS.uitems(c, FD.array__slots(U32, M)), VS.uitems(c, VS.wtake(Nat.double(c), FD.array__slots(U32, M))), ut(c, FD.array__slots(U32, M))) : {S.Sequence{_} == PU64.VALw(t, x, len) : S.Value}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.double(c), FD.array__slots(U32, M)), UR.RWS(Nat.double(c), t, x), ew) : {S.Sequence{VS.uitems(c, _)} == PU64.VALw(t, x, len) : S.Value}
  {==}
"""


def gprog_text():
    J = lambda W, k, ln=False: (f'{W}.XJ{k}(t, x)', f'{W}.FJ{k}(off, t, x)', f'{W}.LJ{k}(t, x' + (', len)' if ln else ')'))  # noqa: E731
    def jargs(W, k, ln=False):
        xj, fj, lj = J(W, k, ln)
        return f'd, t, {xj}, {fj}, {lj}, {W}.eoJ{k}({GP_WA}), hd, {W}.hwJ{k}({GP_WA}), pf, {W}.itD{k}(t, x, off, len, h)'
    PBJ = lambda W, k, CH, ln: (f'S.BitsValue{{BO.bview({CH}.OBJw({", ".join(("d", "t") + J(W, k, ln))}))}}', f'{CH}.VALw(t, {J(W, k, ln)[0]}, {J(W, k, ln)[2]})',  # noqa: E731
                                f'Equal.cong(+List<Bool>, S.Value, z => S.BitsValue{{z}}, BO.bview({CH}.OBJw({", ".join(("d", "t") + J(W, k, ln))})), '
                                f'VBL.bl(UW.WX(t, {J(W, k, ln)[0]}, U32.to_nat({J(W, k, ln)[2]}))), GPB.pbv({jargs(W, k, ln)}))')
    L16 = lambda W, k, CH, tag, ln: (f'PBF.vview2({CH}.OBJw({", ".join(("d", "t") + J(W, k, ln))}))', f'{CH}.VALw(t, {J(W, k, ln)[0]}, {J(W, k, ln)[2]})',  # noqa: E731
                                     f'lv_{tag}({jargs(W, k, ln)})')
    U8 = lambda W, o: (f'RN.v_u8(FX8.OBJ(d, t, Nat.add(x, U32.to_nat({o}))))', f'FX8.VAL(t, Nat.add(x, U32.to_nat({o})))', None)  # noqa: E731
    body = [gp_lv('l123', 'L123'), GP_PL,
            '# ProgressiveSingleListContainerTestStruct: one progressive bit list',
            gp_view('Gp4B0CA2906A', 'W4B', [PBJ('W4B', 0, 'W4B_CH0', True)]),
            '# ProgressiveVarTestStruct: a uint8, a List[uint16, 123], a progressive bit list',
            gp_view('Gp66304057C3', 'W663', [U8('W663', 0), L16('W663', 0, 'L123', 'l123', False), PBJ('W663', 1, 'PBW', True)])]
    head = ['import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/vbuf.bend as VB',
            'import ../proofs/obj/vua_win.bend as UW', 'import ../proofs/obj/vbitl.bend as VBL', 'import ../proofs/obj/words_obj.bend as WO',
            'import ../proofs/obj/packed_bytes.bend as PBF', 'import ../proofs/obj/pb_min.bend as PBM', 'import ../proofs/obj/bitlist_obj.bend as BO',
            'import ../proofs/obj/root_gtypes2.bend as RT2', 'import ../proofs/obj/root_gnames.bend as RN', 'import ../proofs/obj/vfx_u8.bend as FX8',
            'import ../proofs/obj/big_var_winp_pbits.bend as PBW', 'import ../proofs/obj/var_winx_l123_u16.bend as L123',
            'import ../proofs/obj/big_var_winx_Gp4B0CA2906A.bend as W4B', 'import ../proofs/obj/big_var_winp_pbits.bend as W4B_CH0',
            'import ../proofs/obj/big_var_winx_Gp66304057C3.bend as W663',
            'import ./e2e_blist.bend as BL', 'import ./e2e_plist.bend as PL', 'import ./e2e_gpb.bend as GPB',
            'import ../proofs/obj/big_var_winp_u8.bend as PU8', 'import ../proofs/obj/big_var_winp_pl_u64.bend as PU64', 'import ../proofs/obj/ulist_obj.bend as UL',
            'import ../proofs/obj/vspec.bend as VS', 'import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vcopy.bend as VC', 'import ../proofs/obj/vbig.bend as VBG',
            'import ../proofs/obj/vlist.bend as VLS', 'import ../proofs/obj/vua_ct.bend as UCT', 'import ../proofs/obj/vua_rd.bend as UR', 'import ../proofs/obj/var_elems.bend as EL',
            'import ./e2e_plw.bend as PW', 'import ./e2e_bx.bend as BXW', 'import ../proofs/nat_order.bend as Order']
    return '\n'.join(head) + '''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# The progressive containers read at a byte window (x, off, len): the object's root view is its codec
# value (vw_X), part by part: a uint8 by evaluation, a List[uint16, N] (lv_N), a progressive bit list
# (e2e_gpb.pbv).

''' + '\n'.join(body)


SUPPORT_OUT['e2e_gprog.bend'] = gprog_text()
UNION_CHILD['big_var_winx_Gp4B0CA2906A.bend'] = 'GP.vw_Gp4B0CA2906A'
UNION_CHILD['big_var_winx_Gp66304057C3.bend'] = 'GP.vw_Gp66304057C3'


# ---- e2e_grl: fixed-size record lists read at a byte window (var_rlist_sub windows) ------------------------
# GRL[tag] = (window module, its alias, element type module alias + name, record size, fields [(kind, byte offset)])
GRL = {
    'pl_Gc4ED9619F50': ('big_var_winx_pl_Gc4ED9619F50', 'RL4', 'SmallTestStruct_d', 'Gc4ED9619F50', 4, [('u16', 0), ('u16', 2)]),
    'l10_GpF350A3C486': ('var_winx_l10_GpF350A3C486', 'RL1', 'ProgressiveSingleFieldContainerTestStruct_d', 'GpF350A3C486', 1, [('u8', 0)]),
}
GRL_TYPES = {'SmallTestStruct_d': 'SmallTestStruct_def_generated', 'ProgressiveSingleFieldContainerTestStruct_d': 'ProgressiveSingleFieldContainerTestStruct_def_generated'}

GRL_SHARED = r"""# ---- a uint16 read at byte x with only x + 2 (not x + 4) within the buffer ----
def q0b(+q: Nat, +r: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(Nat.add(A.quad(q), r), 2n), A.quad(P)) == True{} : Bool}) -> {Nat.is_lt(q, P) == True{} : Bool}:
  VR.lt_quad(q, P, FD.nat__le_lt_trans(A.quad(q), Nat.add(A.quad(q), r), A.quad(P), FD.nat__le_add_right(A.quad(q), r),
    FD.nat__lt_le_trans(Nat.add(A.quad(q), r), Nat.add(Nat.add(A.quad(q), r), 2n), A.quad(P), VTX.ltp(Nat.add(A.quad(q), r), 1n), h)))

def q1b(+q: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(Nat.add(A.quad(q), 3n), 2n), A.quad(P)) == True{} : Bool}) -> {Nat.is_lt(1n+q, P) == True{} : Bool}:
  +e = Equal.trans(Nat, Nat.add(Nat.add(A.quad(q), 3n), 2n), Nat.add(A.quad(q), 5n), 1n+A.quad(1n+q), FD.nat__add_assoc(A.quad(q), 3n, 2n), FD.nat__add_comm(A.quad(q), 5n))
  VR.lt_quad(1n+q, P, FD.nat__succ_le_lt(A.quad(1n+q), A.quad(P), FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(P)) == True{} : Bool}, Nat.add(Nat.add(A.quad(q), 3n), 2n), 1n+A.quad(1n+q), e, h)))

def byt2(+W: List<&2, U32>, +q: Nat, +r: Nat) -> {VS.bt(2n, VS.bdr(Nat.add(A.quad(q), r), FX.limbs(W))) == VS.bt(2n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(A.quad(q), r), FX.limbs(W)), VS.bdr(r, VS.bdr(A.quad(q), FX.limbs(W))), VN.bdr_add(A.quad(q), r, FX.limbs(W))) : {VS.bt(2n, _) == VS.bt(2n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(A.quad(q), FX.limbs(W)), FX.limbs(VS.wdr0(q, W)), VS.bdr_limbs(q, W)) : {VS.bt(2n, VS.bdr(r, _)) == VS.bt(2n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(q, W), VB.wdr(q, W), VN.wdr0_eq(q, W)) : {VS.bt(2n, VS.bdr(r, FX.limbs(_))) == VS.bt(2n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))) : +List<U32>}
  {==}

# the first two bytes of the word read at 4 q + r: word q's, and word q + 1's only at r = 3
def bytes2(+W: List<&2, U32>, +q: Nat, +r: Nat, +P: Nat, +eL: {VB.len(W) == P : Nat}, +hr: {Nat.is_lt(r, 4n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(Nat.add(A.quad(q), r), 2n), A.quad(P)) == True{} : Bool})
    -> {VS.bt(2n, FX.limbs([UA.jn(r, FD.flat__nthc(W, q), FD.flat__nthc(W, 1n+q))])) == VS.bt(2n, VS.bdr(r, FX.limbs(VB.wdr(q, W)))) : +List<U32>}:
  match r:
    case 0n:
      %Equal.sym(List<&2, U32>, VB.wdr(q, W), Con{FD.flat__nthc(W, q), VB.wdr(1n+q, W)}, VB.wdr_eta(q, W, FD.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, P, VB.len(W), Equal.sym(Nat, VB.len(W), P, eL), q0b(q, 0n, P, h)))) :
        {VS.bt(2n, FX.limbs([FD.flat__nthc(W, q)])) == VS.bt(2n, VS.bdr(0n, FX.limbs(_))) : +List<U32>}
      {==}
@JCASES@
    case 3n:
      +h1 = FD.logic__subst(Nat, z => {Nat.is_lt(1n+q, z) == True{} : Bool}, P, VB.len(W), Equal.sym(Nat, VB.len(W), P, eL), q1b(q, P, h))
      %Equal.sym(List<&2, U32>, VB.wdr(q, W), Con{FD.flat__nthc(W, q), Con{FD.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}}, UA.wtwo(q, W, h1)) :
        {VS.bt(2n, FX.limbs([B.join_sel(3, FD.flat__nthc(W, q), FD.flat__nthc(W, 1n+q))])) == VS.bt(2n, VS.bdr(3n, FX.limbs(_))) : +List<U32>}
      %Equal.sym(List<&2, U32>, I.limb(B.join_sel(3, FD.flat__nthc(W, q), FD.flat__nthc(W, 1n+q))), [I.at(I.limb(FD.flat__nthc(W, q)), 3n), I.at(I.limb(FD.flat__nthc(W, 1n+q)), 0n), I.at(I.limb(FD.flat__nthc(W, 1n+q)), 1n), I.at(I.limb(FD.flat__nthc(W, 1n+q)), 2n)], UB.join3(FD.flat__nthc(W, q), FD.flat__nthc(W, 1n+q))) :
        {VS.bt(2n, List.append(&2, U32, _, [])) == VS.bt(2n, VS.bdr(3n, FX.limbs(Con{FD.flat__nthc(W, q), Con{FD.flat__nthc(W, 1n+q), VB.wdr(2n+q, W)}}))) : +List<U32>}
      {==}
    case 4n+s: Empty.absurd({VS.bt(2n, FX.limbs([UA.jn(4n+s, FD.flat__nthc(W, q), FD.flat__nthc(W, 1n+q))])) == VS.bt(2n, VS.bdr(4n+s, FX.limbs(VB.wdr(q, W)))) : +List<U32>}, FD.nat__lt_zero_absurd(s, hr))

# the first two bytes of the word read at k are the buffer's spec bytes [k, k + 2), k + 2 within it
def rwn2(+d: Nat, +t: FD.array__Tree<U32>, +k: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(k, 2n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {VS.bt(2n, FX.limbs([UR.RWN(t, k)])) == VS.bt(2n, VS.bdr(k, UA.BYT(t))) : +List<U32>}:
  +q = UR.d4(k)
  +r = UR.m4(k)
  +h2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 2n), A.quad(VB.pw(d))) == True{} : Bool}, k, Nat.add(A.quad(q), r), Equal.sym(Nat, Nat.add(A.quad(q), r), k, UR.dm4(k)), h)
  %UR.dm4(k) : {VS.bt(2n, FX.limbs([UR.RWN(t, k)])) == VS.bt(2n, VS.bdr(_, UA.BYT(t))) : +List<U32>}
  Equal.trans(+List<U32>, VS.bt(2n, FX.limbs([UR.RWN(t, k)])), VS.bt(2n, VS.bdr(r, FX.limbs(VB.wdr(q, UA.SL(t))))), VS.bt(2n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(t))),
    bytes2(UA.SL(t), q, r, VB.pw(d), FD.array__slots_length(U32, d, t, pf), UR.m4_lt(k), h2),
    Equal.sym(+List<U32>, VS.bt(2n, VS.bdr(Nat.add(A.quad(q), r), UA.BYT(t))), VS.bt(2n, VS.bdr(r, FX.limbs(VB.wdr(q, UA.SL(t))))), byt2(UA.SL(t), q, r)))

def b2x(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(x, 2n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {[U32.and(UR.RWN(t, x), 255), U32.and(U32.shrn(UR.RWN(t, x), 8n), 255)] == [FX8.BX(t, x), FX8.BX(t, 1n+x)] : +List<U32>}:
  +hl = FD.nat__succ_le_lt(1n+x, A.quad(VB.pw(d)), FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(x, 2n), Nat.add(2n, x), FD.nat__add_comm(x, 2n), h))
  +hB = FD.logic__subst(Nat, z => {Nat.is_lt(1n+x, z) == True{} : Bool}, A.quad(VB.pw(d)), List.length(&2, U32, UA.BYT(t)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(t)), A.quad(VB.pw(d)), FX8.lenB(d, t, pf)), hl)
  Equal.trans(+List<U32>, VS.bt(2n, FX.limbs([UR.RWN(t, x)])), VS.bt(2n, VS.bdr(x, UA.BYT(t))), [VBL.nthb(UA.BYT(t), x), VBL.nthb(UA.BYT(t), 1n+x)],
    rwn2(d, t, x, pf, h), FX8.bt2(UA.BYT(t), x, hB))

# a uint16 read at byte x is the spec's uint16 of its two bytes (x + 2 within the buffer)
def v16w2(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(x, 2n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {O.keep(2, UR.RWN(t, x)) == PB.v16of(FX8.BX(t, x), FX8.BX(t, 1n+x)) : U32}:
  +R = UR.RWN(t, x)
  +eb = b2x(d, t, x, pf, h)
  +e0 = Equal.cong(+List<U32>, U32, l => GW.h0(l), [U32.and(R, 255), U32.and(U32.shrn(R, 8n), 255)], [FX8.BX(t, x), FX8.BX(t, 1n+x)], eb)
  +e1 = Equal.cong(+List<U32>, U32, l => GW.h1(l), [U32.and(R, 255), U32.and(U32.shrn(R, 8n), 255)], [FX8.BX(t, x), FX8.BX(t, 1n+x)], eb)
  Equal.trans(U32, O.keep(2, R), PB.v16of(U32.and(R, 255), U32.and(U32.shrn(R, 8n), 255)), PB.v16of(FX8.BX(t, x), FX8.BX(t, 1n+x)), GW.kv16(R),
    Equal.trans(U32, PB.v16of(U32.and(R, 255), U32.and(U32.shrn(R, 8n), 255)), PB.v16of(FX8.BX(t, x), U32.and(U32.shrn(R, 8n), 255)), PB.v16of(FX8.BX(t, x), FX8.BX(t, 1n+x)),
      Equal.cong(U32, U32, z => PB.v16of(z, U32.and(U32.shrn(R, 8n), 255)), U32.and(R, 255), FX8.BX(t, x), e0),
      Equal.cong(U32, U32, z => PB.v16of(FX8.BX(t, x), z), U32.and(U32.shrn(R, 8n), 255), FX8.BX(t, 1n+x), e1)))

# ---- positions ----
# a field [o, o + w) of the record at y lies within y + R
def fb(+y: Nat, +o: Nat, +w: Nat, +R: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(y, R), P) == True{} : Bool}, +hc: {Nat.is_le(Nat.add(o, w), R) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(o, y), w), P) == True{} : Bool}:
  +e = Equal.trans(Nat, Nat.add(Nat.add(o, y), w), Nat.add(o, Nat.add(y, w)), Nat.add(y, Nat.add(o, w)), FD.nat__add_assoc(o, y, w), FD.lru_nat_algebra__add_swap(o, y, w))
  FD.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(y, Nat.add(o, w)), Nat.add(Nat.add(o, y), w), Equal.sym(Nat, Nat.add(Nat.add(o, y), w), Nat.add(y, Nat.add(o, w)), e),
    FD.nat__le_trans(Nat.add(y, Nat.add(o, w)), Nat.add(y, R), P, Order.add_left(y, Nat.add(o, w), R, hc), h))

def jlt(+k: Nat, +j: Nat, +P: Nat, +h: {Nat.is_lt(Nat.add(k, j), P) == True{} : Bool}) -> {Nat.is_lt(j, P) == True{} : Bool}:
  FD.nat__le_lt_trans(j, Nat.add(k, j), P, Order.left_below_sum(k, j), h)

def hsu(+q: Nat, +j: Nat, +P: Nat, +h: {Nat.is_lt(1n+Nat.add(q, j), P) == True{} : Bool}) -> {Nat.is_lt(Nat.add(q, 1n+j), P) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_lt(z, P) == True{} : Bool}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), h)

# record i + 1's end is within record k + 1's (i <= k)
def rend(+i: Nat, +k: Nat, +R: Nat, +x: Nat, +P: Nat, +hik: {Nat.is_le(i, k) == True{} : Bool}, +h: {Nat.is_le(VRL.pos(1n+k, R, x), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VRL.pos(i, R, x), R), P) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, VRL.pos(1n+i, R, x), Nat.add(VRL.pos(i, R, x), R), Equal.sym(Nat, Nat.add(VRL.pos(i, R, x), R), VRL.pos(1n+i, R, x), VRL.pnx(i, R, x)),
    FD.nat__le_trans(VRL.pos(1n+i, R, x), VRL.pos(1n+k, R, x), P, Order.add_right(Nat.mul(1n+i, R), Nat.mul(1n+k, R), x, VRL.mul_mono(1n+i, 1n+k, R, hik)), h))
"""

GRL_JCASE = r"""    case @R@n:
      %Equal.sym(List<&2, U32>, VB.wdr(q, W), Con{FD.flat__nthc(W, q), VB.wdr(1n+q, W)}, VB.wdr_eta(q, W, FD.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, P, VB.len(W), Equal.sym(Nat, VB.len(W), P, eL), q0b(q, @R@n, P, h)))) :
        {VS.bt(2n, FX.limbs([B.join_sel(@R@, FD.flat__nthc(W, q), FD.flat__nthc(W, 1n+q))])) == VS.bt(2n, VS.bdr(@R@n, FX.limbs(_))) : +List<U32>}
      %Equal.sym(List<&2, U32>, I.limb(B.join_sel(@R@, FD.flat__nthc(W, q), FD.flat__nthc(W, 1n+q))), [@AT@], UB.join@R@(FD.flat__nthc(W, q), FD.flat__nthc(W, 1n+q))) :
        {VS.bt(2n, List.append(&2, U32, _, [])) == VS.bt(2n, VS.bdr(@R@n, FX.limbs(Con{FD.flat__nthc(W, q), VB.wdr(1n+q, W)}))) : +List<U32>}
      {==}"""

GRL_PER = r"""# ---- @TAG@: records of @RS@ bytes (@EN@) ----
# the record at y is the spec's value of its bytes (y + @RS@ within the buffer)
def ev_@TAG@(+d: Nat, +t: FD.array__Tree<U32>, +y: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(y, @RS@n), A.quad(VB.pw(d))) == True{} : Bool}) -> {RN.v_@EN@(@W@.RX(t, y)) == @W@.RVAL(t, y) : S.Value}:
@EVBODY@

# writing record j leaves the others
def kp1_@TAG@(+dd: Nat, +D: FD.array__Tree<@ET@>, +j: Nat, +v: @ET@, +i: Nat, +hi: {Nat.is_lt(i, j) == True{} : Bool},
    +hj: {Nat.is_lt(j, FD.spec_common__pow2(dd)) == True{} : Bool}, +pf: {FD.array__perfect(@ET@, dd, D) == True{} : Bool})
    -> {FD.spec_common__nth(@ET@, FD.array__slots(@ET@, FD.array__upd(@ET@, dd, D, j, v)), i) == FD.spec_common__nth(@ET@, FD.array__slots(@ET@, D), i) : Maybe<&2, @ET@>}:
  %Equal.sym(List<&2, @ET@>, FD.array__slots(@ET@, FD.array__upd(@ET@, dd, D, j, v)), FD.spec_common__update(@ET@, FD.array__slots(@ET@, D), j, v), FD.array__upd_slots(@ET@, dd, D, j, v, hj, pf)) :
    {FD.spec_common__nth(@ET@, _, i) == FD.spec_common__nth(@ET@, FD.array__slots(@ET@, D), i) : Maybe<&2, @ET@>}
  FD.list__nth_update_other(@ET@, FD.array__slots(@ET@, D), j, i, v, FD.flat__ne_gt(j, i, hi))

# ... and holds record j
def at0_@TAG@(+dd: Nat, +D: FD.array__Tree<@ET@>, +j: Nat, +v: @ET@, +hj: {Nat.is_lt(j, FD.spec_common__pow2(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(@ET@, dd, D) == True{} : Bool})
    -> {FD.spec_common__nth(@ET@, FD.array__slots(@ET@, FD.array__upd(@ET@, dd, D, j, v)), j) == Some{v} : Maybe<&2, @ET@>}:
  +hl = FD.logic__subst(Nat, z => {Nat.is_lt(j, z) == True{} : Bool}, FD.spec_common__pow2(dd), FD.spec_common__length(@ET@, FD.array__slots(@ET@, D)),
    Equal.sym(Nat, FD.spec_common__length(@ET@, FD.array__slots(@ET@, D)), FD.spec_common__pow2(dd), FD.array__slots_length(@ET@, dd, D, pf)), hj)
  %Equal.sym(List<&2, @ET@>, FD.array__slots(@ET@, FD.array__upd(@ET@, dd, D, j, v)), FD.spec_common__update(@ET@, FD.array__slots(@ET@, D), j, v), FD.array__upd_slots(@ET@, dd, D, j, v, hj, pf)) :
    {FD.spec_common__nth(@ET@, _, j) == Some{v} : Maybe<&2, @ET@>}
  FD.list__nth_update_same(@ET@, FD.array__slots(@ET@, D), j, v, hl)

def pfRT_@TAG@(k: Nat, +j: Nat, +dd: Nat, +D: FD.array__Tree<@ET@>, +t: FD.array__Tree<U32>, +x: Nat, +pf: {FD.array__perfect(@ET@, dd, D) == True{} : Bool})
    -> {FD.array__perfect(@ET@, dd, @W@.RT(k, j, dd, D, t, x)) == True{} : Bool}:
  match k:
    case 0n: FD.array__upd_perfect(@ET@, dd, D, j, @W@.RX(t, VRL.pos(j, @RS@n, x)), pf)
    case 1n+ +q: pfRT_@TAG@(q, 1n+j, dd, FD.array__upd(@ET@, dd, D, j, @W@.RX(t, VRL.pos(j, @RS@n, x))), t, x, FD.array__upd_perfect(@ET@, dd, D, j, @W@.RX(t, VRL.pos(j, @RS@n, x)), pf))

# the records j .. j + k leave the slots below j
def keep_@TAG@(k: Nat, +j: Nat, +dd: Nat, +D: FD.array__Tree<@ET@>, +t: FD.array__Tree<U32>, +x: Nat, +i: Nat,
    +hi: {Nat.is_lt(i, j) == True{} : Bool}, +hb: {Nat.is_lt(Nat.add(k, j), FD.spec_common__pow2(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(@ET@, dd, D) == True{} : Bool})
    -> {FD.spec_common__nth(@ET@, FD.array__slots(@ET@, @W@.RT(k, j, dd, D, t, x)), i) == FD.spec_common__nth(@ET@, FD.array__slots(@ET@, D), i) : Maybe<&2, @ET@>}:
  match k:
    case 0n: kp1_@TAG@(dd, D, j, @W@.RX(t, VRL.pos(j, @RS@n, x)), i, hi, hb, pf)
    case 1n+ +q:
      +v = @W@.RX(t, VRL.pos(j, @RS@n, x))
      +D1 = FD.array__upd(@ET@, dd, D, j, v)
      Equal.trans(Maybe<&2, @ET@>, FD.spec_common__nth(@ET@, FD.array__slots(@ET@, @W@.RT(q, 1n+j, dd, D1, t, x)), i), FD.spec_common__nth(@ET@, FD.array__slots(@ET@, D1), i), FD.spec_common__nth(@ET@, FD.array__slots(@ET@, D), i),
        keep_@TAG@(q, 1n+j, dd, D1, t, x, i, FD.nat__lt_trans(i, j, 1n+j, hi, FD.nat__lt_succ(j)), hsu(q, j, FD.spec_common__pow2(dd), hb), FD.array__upd_perfect(@ET@, dd, D, j, v, pf)),
        kp1_@TAG@(dd, D, j, v, i, hi, jlt(1n+q, j, FD.spec_common__pow2(dd), hb), pf))

# ... and hold record r + j there (r <= k)
def at_@TAG@(k: Nat, r: Nat, +j: Nat, +dd: Nat, +D: FD.array__Tree<@ET@>, +t: FD.array__Tree<U32>, +x: Nat,
    +hr: {Nat.is_le(r, k) == True{} : Bool}, +hb: {Nat.is_lt(Nat.add(k, j), FD.spec_common__pow2(dd)) == True{} : Bool},
    +pf: {FD.array__perfect(@ET@, dd, D) == True{} : Bool})
    -> {FD.spec_common__nth(@ET@, FD.array__slots(@ET@, @W@.RT(k, j, dd, D, t, x)), Nat.add(r, j)) == Some{@W@.RX(t, VRL.pos(Nat.add(r, j), @RS@n, x))} : Maybe<&2, @ET@>}:
  match k r:
    case 0n 0n: at0_@TAG@(dd, D, j, @W@.RX(t, VRL.pos(j, @RS@n, x)), hb, pf)
    case 0n 1n+ +p: Empty.absurd({FD.spec_common__nth(@ET@, FD.array__slots(@ET@, @W@.RT(0n, j, dd, D, t, x)), Nat.add(1n+p, j)) == Some{@W@.RX(t, VRL.pos(Nat.add(1n+p, j), @RS@n, x))} : Maybe<&2, @ET@>}, FD.logic__false_true(hr))
    case 1n+ +q 0n:
      +v = @W@.RX(t, VRL.pos(j, @RS@n, x))
      +D1 = FD.array__upd(@ET@, dd, D, j, v)
      Equal.trans(Maybe<&2, @ET@>, FD.spec_common__nth(@ET@, FD.array__slots(@ET@, @W@.RT(q, 1n+j, dd, D1, t, x)), j), FD.spec_common__nth(@ET@, FD.array__slots(@ET@, D1), j), Some{v},
        keep_@TAG@(q, 1n+j, dd, D1, t, x, j, FD.nat__lt_succ(j), hsu(q, j, FD.spec_common__pow2(dd), hb), FD.array__upd_perfect(@ET@, dd, D, j, v, pf)),
        at0_@TAG@(dd, D, j, v, jlt(1n+q, j, FD.spec_common__pow2(dd), hb), pf))
    case 1n+ +q 1n+ +p:
      +v = @W@.RX(t, VRL.pos(j, @RS@n, x))
      +D1 = FD.array__upd(@ET@, dd, D, j, v)
      %FD.nat__add_succ(p, j) : {FD.spec_common__nth(@ET@, FD.array__slots(@ET@, @W@.RT(q, 1n+j, dd, D1, t, x)), _) == Some{@W@.RX(t, VRL.pos(_, @RS@n, x))} : Maybe<&2, @ET@>}
      at_@TAG@(q, p, 1n+j, dd, D1, t, x, hr, hsu(q, j, FD.spec_common__pow2(dd), hb), FD.array__upd_perfect(@ET@, dd, D, j, v, pf))

# the root's element at i of a list whose i-th is Some{v}
def xa_@TAG@(+W: List<&2, @ET@>, +i: Nat, +v: @ET@, +hi: {Nat.is_lt(i, FD.spec_common__length(@ET@, W)) == True{} : Bool},
    +e: {FD.spec_common__nth(@ET@, W, i) == Some{v} : Maybe<&2, @ET@>}) -> {RT2.xat_@TAG@(W, i) == v : @ET@}:
  Equal.cong(Maybe<&2, @ET@>, @ET@, m => VRL.mget(@ET@, m, @ET@_default()), Some{RT2.xat_@TAG@(W, i)}, Some{v},
    Equal.trans(Maybe<&2, @ET@>, Some{RT2.xat_@TAG@(W, i)}, FD.spec_common__nth(@ET@, W, i), Some{v},
      Equal.sym(Maybe<&2, @ET@>, FD.spec_common__nth(@ET@, W, i), Some{RT2.xat_@TAG@(W, i)}, RT2.nth_@TAG@(W, i, hi)), e))

# the root's items from i of the records 0 .. k written into a fresh tree: the spec's records from byte pos(i)
def xs_@TAG@(q: Nat, +i: Nat, +k: Nat, +dd: Nat, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hq: {Nat.is_le(Nat.add(q, i), 1n+k) == True{} : Bool}, +hb: {Nat.is_lt(Nat.add(k, 0n), FD.spec_common__pow2(dd)) == True{} : Bool},
    +hw: {Nat.is_le(VRL.pos(1n+k, @RS@n, x), A.quad(VB.pw(d))) == True{} : Bool})
    -> {RT2.xi_@TAG@(q, FD.array__slots(@ET@, @W@.RT(k, 0n, dd, FD.array__trep(@ET@, dd, @ET@_default()), t, x)), i) == @W@.RITEMS(q, t, VRL.pos(i, @RS@n, x)) : S.Value}:
  match q:
    case 0n: {==}
    case 1n+ +p:
      +TR = FD.array__trep(@ET@, dd, @ET@_default())
      +SL = FD.array__slots(@ET@, @W@.RT(k, 0n, dd, TR, t, x))
      +pT = FD.array__trep_perfect(@ET@, dd, @ET@_default())
      +hik = FD.nat__le_trans(i, Nat.add(p, i), k, Order.left_below_sum(p, i), hq)
      +ea = FD.logic__subst(Nat, z => {FD.spec_common__nth(@ET@, SL, z) == Some{@W@.RX(t, VRL.pos(z, @RS@n, x))} : Maybe<&2, @ET@>}, Nat.add(i, 0n), i, FD.nat__add_zero(i), at_@TAG@(k, i, 0n, dd, TR, t, x, hik, hb, pT))
      +hl = FD.logic__subst(Nat, z => {Nat.is_lt(i, z) == True{} : Bool}, FD.spec_common__pow2(dd), FD.spec_common__length(@ET@, SL),
        Equal.sym(Nat, FD.spec_common__length(@ET@, SL), FD.spec_common__pow2(dd), FD.array__slots_length(@ET@, dd, @W@.RT(k, 0n, dd, TR, t, x), pfRT_@TAG@(k, 0n, dd, TR, t, x, pT))),
        FD.nat__le_lt_trans(i, k, FD.spec_common__pow2(dd), hik, FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(dd)) == True{} : Bool}, Nat.add(k, 0n), k, FD.nat__add_zero(k), hb)))
      +ex = xa_@TAG@(SL, i, @W@.RX(t, VRL.pos(i, @RS@n, x)), hl, ea)
      +ev = ev_@TAG@(d, t, VRL.pos(i, @RS@n, x), pf, rend(i, k, @RS@n, x, A.quad(VB.pw(d)), hik, hw))
      +hq1 = FD.logic__subst(Nat, z => {Nat.is_le(z, 1n+k) == True{} : Bool}, 1n+Nat.add(p, i), Nat.add(p, 1n+i), Equal.sym(Nat, Nat.add(p, 1n+i), 1n+Nat.add(p, i), FD.nat__add_succ(p, i)), hq)
      +ih = xs_@TAG@(p, 1n+i, k, dd, d, t, x, pf, hq1, hb, hw)
      %Equal.sym(Nat, Nat.add(@RS@n, VRL.pos(i, @RS@n, x)), VRL.pos(1n+i, @RS@n, x), VRL.pnx0(i, @RS@n, x)) :
        {S.Items{RN.v_@EN@(RT2.xat_@TAG@(SL, i)), RT2.xi_@TAG@(p, SL, 1n+i)} == S.Items{@W@.RVAL(t, VRL.pos(i, @RS@n, x)), @W@.RITEMS(p, t, _)} : S.Value}
      %ih : {S.Items{RN.v_@EN@(RT2.xat_@TAG@(SL, i)), RT2.xi_@TAG@(p, SL, 1n+i)} == S.Items{@W@.RVAL(t, VRL.pos(i, @RS@n, x)), _} : S.Value}
      %ev : {S.Items{RN.v_@EN@(RT2.xat_@TAG@(SL, i)), RT2.xi_@TAG@(p, SL, 1n+i)} == S.Items{_, RT2.xi_@TAG@(p, SL, 1n+i)} : S.Value}
      %Equal.sym(@ET@, RT2.xat_@TAG@(SL, i), @W@.RX(t, VRL.pos(i, @RS@n, x)), ex) : {S.Items{RN.v_@EN@(_), RT2.xi_@TAG@(p, SL, 1n+i)} == S.Items{RN.v_@EN@(@W@.RX(t, VRL.pos(i, @RS@n, x))), RT2.xi_@TAG@(p, SL, 1n+i)} : S.Value}
      {==}

def go_@TAG@(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hc: {@W@.CHKw(t, x, off, len) == True{} : Bool}, +b: Bool, +eb: {U32.is_eq(len, 0) == b : Bool})
    -> {RT2.xv_@TAG@(@W@.LOBJ(b, t, x, len)) == @W@.VALw(t, x, len) : S.Value}:
  match b:
    case True{}:
      %Equal.sym(U32, len, 0, FD.u32alg__eq_of(len, 0, eb)) : {RT2.xv_@TAG@(@W@.LOBJ(True{}, t, x, len)) == S.Sequence{@W@.RITEMS(@W@.CC(_), t, x)} : S.Value}
      {==}
    case False{}:
      +c = @W@.CC(len)
      +ec = @W@.ecw(len, hc)
      +h1 = @W@.cpos(len, c, ec, eb)
      +k = U32.to_nat(U32.sub(@W@.NN(len), 1))
      +e1 = Equal.trans(Nat, 1n+k, 1n+Nat.sub(c, 1n), c, Equal.cong(Nat, Nat, z => 1n+z, k, Nat.sub(c, 1n), FD.u32__sub_nat(@W@.NN(len), 1, h1)), FD.nat__sub_add(c, 1n, h1))
      +P = A.quad(VB.pw(d))
      +hL = FD.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw)
      +hLc = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, x), P) == True{} : Bool}, U32.to_nat(len), Nat.mul(c, @RS@n), ec, hL)
      +hw2 = FD.logic__subst(Nat, z => {Nat.is_le(VRL.pos(z, @RS@n, x), P) == True{} : Bool}, c, 1n+k, Equal.sym(Nat, 1n+k, c, e1), hLc)
      +hcN = FD.logic__subst(Nat, z => {Nat.is_le(c, z) == True{} : Bool}, VB.pw(2n+d), O.pow2n(2n+d), VD.s_pow2_eq(2n+d),
        FD.nat__le_trans(c, Nat.mul(c, @RS@n), VB.pw(2n+d), VRL.le_mul(c, @RS1@n),
          FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(2n+d)) == True{} : Bool}, U32.to_nat(len), Nat.mul(c, @RS@n), ec,
            FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw))))
      +hcp = VD.wd_cover(@W@.NN(len), 2n+d, FD.nat__lt_le(d, 30n, FD.nat__lt_trans(d, 28n, 30n, hd, {==})), hcN)
      +hcP = FD.logic__subst(Nat, z => {Nat.is_le(c, z) == True{} : Bool}, O.pow2n(B.words_depth(@W@.NN(len))), VB.pw(B.words_depth(@W@.NN(len))), Equal.sym(Nat, VB.pw(B.words_depth(@W@.NN(len))), O.pow2n(B.words_depth(@W@.NN(len))), VD.s_pow2_eq(B.words_depth(@W@.NN(len)))), hcp)
      +hk = FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(B.words_depth(@W@.NN(len)))) == True{} : Bool}, k, Nat.add(k, 0n), Equal.sym(Nat, Nat.add(k, 0n), k, FD.nat__add_zero(k)),
        FD.nat__lt_le_trans(k, c, VB.pw(B.words_depth(@W@.NN(len))), FD.logic__subst(Nat, z => {Nat.is_lt(k, z) == True{} : Bool}, 1n+k, c, e1, FD.nat__lt_succ(k)), hcP))
      +hq = FD.logic__subst(Nat, z => {Nat.is_le(z, 1n+k) == True{} : Bool}, 1n+k, Nat.add(1n+k, 0n), Equal.sym(Nat, Nat.add(1n+k, 0n), 1n+k, FD.nat__add_zero(1n+k)), FD.nat__le_refl(1n+k))
      +RTF = @W@.RT(k, 0n, B.words_depth(@W@.NN(len)), FD.array__trep(@ET@, B.words_depth(@W@.NN(len)), @ET@_default()), t, x)
      %Equal.sym(FD.array__Tree<@ET@>, FD.array__freeze(@ET@, FD.array__thaw(@ET@, RTF)), RTF, FD.array__freeze_thaw(@ET@, RTF)) :
        {S.Sequence{RT2.xi_@TAG@(c, FD.array__slots(@ET@, _), 0n)} == S.Sequence{@W@.RITEMS(c, t, x)} : S.Value}
      %e1 : {S.Sequence{RT2.xi_@TAG@(_, FD.array__slots(@ET@, RTF), 0n)} == S.Sequence{@W@.RITEMS(_, t, x)} : S.Value}
      Equal.cong(S.Value, S.Value, z => S.Sequence{z}, RT2.xi_@TAG@(1n+k, FD.array__slots(@ET@, RTF), 0n), @W@.RITEMS(1n+k, t, x),
        xs_@TAG@(1n+k, 0n, k, B.words_depth(@W@.NN(len)), d, t, x, pf, hq, hk, hw2))

# the root view of the list read at the window (x, off, len) is its codec value
def vl_@TAG@(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hc: {@W@.CHKw(t, x, off, len) == True{} : Bool}) -> {RT2.xv_@TAG@(@W@.OBJw(d, t, x, off, len)) == @W@.VALw(t, x, len) : S.Value}:
  go_@TAG@(d, t, x, off, len, hd, hw, pf, hc, U32.is_eq(len, 0), {==})
"""


def _grl_ev(tag, W, EN, RS, fields):
    """ev_tag's body: rewrite each uint16 field to its bytes' value (uint8 fields agree by evaluation)."""
    def at(o):
        return 'y' if o == 0 else f'{o}n+y'
    lhs = {}
    rhs = {}
    lets = []
    for i, (kd, o) in enumerate(fields):
        if kd == 'u16':
            lhs[i] = f'RN.v_u16(O.keep(2, UR.RWN(t, {at(o)})))'
            rhs[i] = f'FXB.VAL(t, {at(o)})'
            lets.append((i, f'Equal.cong(U32, S.Value, z => S.UnsignedValue{{P.UInt{{z, 0, 0, 0, 0, 0, 0, 0}}}}, O.keep(2, UR.RWN(t, {at(o)})), PB.v16of(FX8.BX(t, {at(o)}), FX8.BX(t, 1n+{at(o)})), '
                            f'v16w2(d, t, Nat.add({o}n, y), pf, fb(y, {o}n, 2n, {RS}n, A.quad(VB.pw(d)), h, {{==}})))'))
        else:
            lhs[i] = rhs[i] = f'FXA.VAL(t, {at(o)})'

    def items(cur, hole):
        s = 'S.EmptyItems{}'
        for i in reversed(range(len(fields))):
            s = f'S.Items{{{"_" if i == hole else (lhs[i] if i < hole else rhs[i])}, {s}}}'
        return f'S.Sequence{{{s}}}'
    out = []
    for i, e in lets:
        out.append(f'  +e{i} = {e}')
    for i, _ in lets:
        out.append(f'  %e{i} : {{RN.v_{EN}({W}.RX(t, y)) == {items(None, i)} : S.Value}}')
    out.append('  {==}')
    return '\n'.join(out)


def grl_text():
    at = {1: ['I.at(I.limb(FD.flat__nthc(W, q)), 1n)', 'I.at(I.limb(FD.flat__nthc(W, q)), 2n)', 'I.at(I.limb(FD.flat__nthc(W, q)), 3n)', 'I.at(I.limb(FD.flat__nthc(W, 1n+q)), 0n)'],
          2: ['I.at(I.limb(FD.flat__nthc(W, q)), 2n)', 'I.at(I.limb(FD.flat__nthc(W, q)), 3n)', 'I.at(I.limb(FD.flat__nthc(W, 1n+q)), 0n)', 'I.at(I.limb(FD.flat__nthc(W, 1n+q)), 1n)']}
    jc = '\n'.join(GRL_JCASE.replace('@R@', str(r)).replace('@AT@', ', '.join(at[r])) for r in (1, 2))
    body = [GRL_SHARED.replace('@JCASES@', jc)]
    imps = []
    for tag, (mod, W, TM, EN, RS, fields) in GRL.items():
        imps.append(f'import ../proofs/obj/{mod}.bend as {W}')
        ET = f'{TM}.{EN}'
        body.append(GRL_PER.replace('@EVBODY@', _grl_ev(tag, W, EN, RS, fields)).replace('@TAG@', tag).replace('@W@', W).replace('@ET@', ET)
                    .replace('@EN@', EN).replace('@RS1@', str(RS - 1)).replace('@RS@', str(RS)))
    for TM, f in GRL_TYPES.items():
        imps.append(f'import ../types/{f}.bend as {TM}')
    head = ['import Base', 'import ../src/obj.bend as O', 'import ../src/buffer.bend as B', 'import ../src/primitives.bend as I',
            'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/nat_order.bend as Order',
            'import ../proofs/obj/spec_fixed.bend as FX', 'import ../proofs/obj/vspec.bend as VS', 'import ../proofs/obj/vbuf.bend as VB',
            'import ../proofs/obj/vnest.bend as VN', 'import ../proofs/obj/vbrt.bend as VR', 'import ../proofs/obj/vua.bend as UA',
            'import ../proofs/obj/vua_bits.bend as UB', 'import ../proofs/obj/vua_rd.bend as UR', 'import ../proofs/obj/vua_fix.bend as VTX',
            'import ../proofs/obj/vbitl.bend as VBL', 'import ../proofs/obj/pb_min.bend as PB', 'import ../proofs/obj/vfx_u8.bend as FX8',
            'import ../proofs/obj/vfx_u8.bend as FXA', 'import ../proofs/obj/vfx_u16.bend as FXB', 'import ../proofs/obj/vrl.bend as VRL',
            'import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/root_gtypes2.bend as RT2', 'import ../proofs/obj/root_gnames.bend as RN',
            'import ./e2e_gwin.bend as GW'] + imps
    return '\n'.join(head) + '''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# Fixed-size record lists read at a byte window (the var_rlist_sub windows): the root view of the list the
# runtime reads (the records 0 .. k written in turn into a fresh tree, RT) is the window's codec value
# (vl_X): slot i of RT holds record i (at_X, keep_X), whose root view is the spec's value of its bytes
# (ev_X; a uint16 field needs only its own two bytes within the buffer, v16w2).

''' + '\n'.join(body)


SUPPORT_OUT['e2e_grl.bend'] = grl_text()


# ---- e2e_gvl: progressive lists of variable-size elements read at a byte window (var_vlist windows) ------------
# GVL[L] = (vvl module, alias, element tag E, element type, def module alias of L, L's def file)
# The element E has tf_E (its object survives RT2.fz_E then RT2.th_E) and vw_E (its root view is its window's
# value), both over (d, t, x, off, len, eo, hd, hw, pf, hc: YW.CHKw); L gets tf_L and vw_L of the same shape, so
# a list of lists nests.
GVL = {
    'pl_Gc465214E502': ('big_vvl_pl_Gc465214E502', 'TA', 'Gc465214E502', 'VarTestStruct_d.Gc465214E502', 'proglist_VarTestStruct_d'),
    'pl_pl_Gc465214E502': ('big_vvl_pl_pl_Gc465214E502', 'TB', 'pl_Gc465214E502', 'proglist_VarTestStruct_d.pl_Gc465214E502_Seq', 'proglist_proglist_VarTestStruct_d'),
    'pl_Gp66304057C3': ('big_vvl_pl_Gp66304057C3', 'TC', 'Gp66304057C3', 'ProgressiveVarTestStruct_d.Gp66304057C3', 'proglist_ProgressiveVarTestStruct_d'),
}
GVL_ELEM = {'pl_Gc465214E502'}  # lists that are elements of another list here: they get tf_L
GVL_TYPES = [('VarTestStruct_d', 'VarTestStruct_def_generated'), ('proglist_VarTestStruct_d', 'proglist_VarTestStruct_def_generated'),
             ('proglist_proglist_VarTestStruct_d', 'proglist_proglist_VarTestStruct_def_generated'),
             ('ProgressiveVarTestStruct_d', 'ProgressiveVarTestStruct_def_generated'), ('proglist_ProgressiveVarTestStruct_d', 'proglist_ProgressiveVarTestStruct_def_generated')]

GVL_WP = ('+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},\n'
          '    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}')

GVL_SHARED = r"""# ---- index facts ----------------------------------------------------------------------------------------
def e1(+i: U32, +q: Nat, +m: U32, +inv: {Nat.add(U32.to_nat(i), 2n+q) == U32.to_nat(m) : Nat}) -> {U32.to_nat(U32.add(i, 1)) == 1n+U32.to_nat(i) : Nat}:
  VVU.addk(i, 1, m, FD.logic__subst(Nat, z => {Nat.is_le(1n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 2n+q), U32.to_nat(m), inv,
    FD.logic__subst(Nat, z => {Nat.is_le(1n+U32.to_nat(i), z) == True{} : Bool}, Nat.add(2n+q, U32.to_nat(i)), Nat.add(U32.to_nat(i), 2n+q), FD.nat__add_comm(2n+q, U32.to_nat(i)),
      A.le_skip(1n+q, U32.to_nat(i)))))

def inv1(+i: U32, +q: Nat, +m: U32, +inv: {Nat.add(U32.to_nat(i), 2n+q) == U32.to_nat(m) : Nat}) -> {Nat.add(U32.to_nat(U32.add(i, 1)), 1n+q) == U32.to_nat(m) : Nat}:
  Equal.trans(Nat, Nat.add(U32.to_nat(U32.add(i, 1)), 1n+q), Nat.add(1n+U32.to_nat(i), 1n+q), U32.to_nat(m),
    Equal.cong(Nat, Nat, z => Nat.add(z, 1n+q), U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1(i, q, m, inv)),
    Equal.trans(Nat, Nat.add(1n+U32.to_nat(i), 1n+q), Nat.add(U32.to_nat(i), 2n+q), U32.to_nat(m), Equal.sym(Nat, Nat.add(U32.to_nat(i), 2n+q), 1n+Nat.add(U32.to_nat(i), 1n+q), FD.nat__add_succ(U32.to_nat(i), 1n+q)), inv))

# i < i + 1 + k == m <= 2^dd
def hiq(+i: U32, +k: Nat, +m: U32, +dd: Nat, +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat}, +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dd)) == True{} : Bool})
    -> {Nat.is_lt(U32.to_nat(i), FD.spec_common__pow2(dd)) == True{} : Bool}:
  FD.nat__lt_le_trans(U32.to_nat(i), U32.to_nat(m), FD.spec_common__pow2(dd),
    FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(i), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 1n+k), U32.to_nat(m), inv,
      FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(i), z) == True{} : Bool}, 1n+Nat.add(U32.to_nat(i), k), Nat.add(U32.to_nat(i), 1n+k), Equal.sym(Nat, Nat.add(U32.to_nat(i), 1n+k), 1n+Nat.add(U32.to_nat(i), k), FD.nat__add_succ(U32.to_nat(i), k)),
        FD.nat__le_lt_trans(U32.to_nat(i), Nat.add(U32.to_nat(i), k), 1n+Nat.add(U32.to_nat(i), k), FD.nat__le_add_right(U32.to_nat(i), k), FD.nat__lt_succ(Nat.add(U32.to_nat(i), k))))), hm)

def isne(+a: Nat, +b: Nat, +h: {Nat.is_lt(a, b) == True{} : Bool}) -> {Nat.is_eq(b, a) == False{} : Bool}:
  match a b:
    case 0n 0n: Empty.absurd({Nat.is_eq(0n, 0n) == False{} : Bool}, FD.logic__false_true(h))
    case 0n 1n+ +q: {==}
    case 1n+ +p 0n: Empty.absurd({Nat.is_eq(0n, 1n+p) == False{} : Bool}, FD.logic__false_true(h))
    case 1n+ +p 1n+ +q: isne(p, q, h)

# s < i + 1 when s < i
def lts(+i: U32, +q: Nat, +m: U32, +s: Nat, +inv: {Nat.add(U32.to_nat(i), 2n+q) == U32.to_nat(m) : Nat}, +h: {Nat.is_lt(s, U32.to_nat(i)) == True{} : Bool})
    -> {Nat.is_lt(s, U32.to_nat(U32.add(i, 1))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_lt(s, z) == True{} : Bool}, 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1(i, q, m, inv)),
    FD.nat__lt_trans(s, U32.to_nat(i), 1n+U32.to_nat(i), h, FD.nat__lt_succ(U32.to_nat(i))))

# thawing a frozen word array gives it back
def thfr(a: Array<U32>) -> {FD.array__thaw(U32, FD.array__freeze(U32, a)) == a : Array<U32>}:
  match a:
    case ALeaf{+w}: {==}
    case ANode{xs, ys}:
      %Equal.sym(Array<U32>, FD.array__thaw(U32, FD.array__freeze(U32, xs)), xs, thfr(xs)) : {ANode{_, FD.array__thaw(U32, FD.array__freeze(U32, ys))} == ANode{xs, ys} : Array<U32>}
      %Equal.sym(Array<U32>, FD.array__thaw(U32, FD.array__freeze(U32, ys)), ys, thfr(ys)) : {ANode{xs, _} == ANode{xs, ys} : Array<U32>}
      {==}

# ---- VarTestStruct elements (var_winx_Gc465214E502) ----
def tf_Gc465214E502(@WP@, +hc: {YW0.CHKw(t, x, off, len) == True{} : Bool})
    -> {RT2.th_Gc465214E502(RT2.fz_Gc465214E502(YW0.OBJw(d, t, x, off, len))) == YW0.OBJw(d, t, x, off, len) : VarTestStruct_d.Gc465214E502}:
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, UCT.CT(d, t, YW0.FJ0(off, t, x), YW0.LJ0(t, x, len), VLS.DZ(YW0.LJ0(t, x, len))))), UCT.CT(d, t, YW0.FJ0(off, t, x), YW0.LJ0(t, x, len), VLS.DZ(YW0.LJ0(t, x, len))),
      FD.array__freeze_thaw(U32, UCT.CT(d, t, YW0.FJ0(off, t, x), YW0.LJ0(t, x, len), VLS.DZ(YW0.LJ0(t, x, len))))) :
    {VarTestStruct_d.Gc465214E502{FX16.OBJ(d, t, Nat.add(x, U32.to_nat(0))), O.Words{FD.array__thaw(U32, _), YW0.LJ0(t, x, len)}, FX8.OBJ(d, t, Nat.add(x, U32.to_nat(6)))} == YW0.OBJw(d, t, x, off, len) : VarTestStruct_d.Gc465214E502}
  {==}

def vw_Gc465214E502(@WP@, +hc: {YW0.CHKw(t, x, off, len) == True{} : Bool})
    -> {RT2.v_Gc465214E502(YW0.OBJw(d, t, x, off, len)) == YW0.VALw(t, x, len) : S.Value}:
  GVT.vtw(d, t, 0, x, off, len, eo, hd, hw, pf, hc)

# ---- ProgressiveVarTestStruct elements (big_var_winx_Gp66304057C3) ----
def tf_Gp66304057C3(@WP@, +hc: {YW1.CHKw(t, x, off, len) == True{} : Bool})
    -> {RT2.th_Gp66304057C3(RT2.fz_Gp66304057C3(YW1.OBJw(d, t, x, off, len))) == YW1.OBJw(d, t, x, off, len) : ProgressiveVarTestStruct_d.Gp66304057C3}:
  +C0 = UCT.CT(d, t, YW1.FJ0(off, t, x), YW1.LJ0(t, x), VLS.DZ(YW1.LJ0(t, x)))
  +C1 = UCT.CT(d, t, YW1.FJ1(off, t, x), YW1.LJ1(t, x, len), VLS.DZ(YW1.LJ1(t, x, len)))
  +NB = PBW.NB(t, YW1.FJ1(off, t, x), YW1.LJ1(t, x, len))
  %Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, C0)), C0, FD.array__freeze_thaw(U32, C0)) :
    {ProgressiveVarTestStruct_d.Gp66304057C3{FX8.OBJ(d, t, Nat.add(x, U32.to_nat(0))), O.Words{FD.array__thaw(U32, _), YW1.LJ0(t, x)}, O.Bits{FD.array__thaw(U32, FD.array__freeze(U32, O.clear_bit(FD.array__thaw(U32, C1), NB))), NB}} == YW1.OBJw(d, t, x, off, len) : ProgressiveVarTestStruct_d.Gp66304057C3}
  %Equal.sym(Array<U32>, FD.array__thaw(U32, FD.array__freeze(U32, O.clear_bit(FD.array__thaw(U32, C1), NB))), O.clear_bit(FD.array__thaw(U32, C1), NB), thfr(O.clear_bit(FD.array__thaw(U32, C1), NB))) :
    {ProgressiveVarTestStruct_d.Gp66304057C3{FX8.OBJ(d, t, Nat.add(x, U32.to_nat(0))), O.Words{FD.array__thaw(U32, C0), YW1.LJ0(t, x)}, O.Bits{_, NB}} == YW1.OBJw(d, t, x, off, len) : ProgressiveVarTestStruct_d.Gp66304057C3}
  {==}

def vw_Gp66304057C3(@WP@, +hc: {YW1.CHKw(t, x, off, len) == True{} : Bool})
    -> {RT2.v_Gp66304057C3(YW1.OBJw(d, t, x, off, len)) == YW1.VALw(t, x, len) : S.Value}:
  GP.vw_Gp66304057C3(d, t, 0, x, off, len, eo, hd, hw, pf, hc)
"""

GVL_PER = r"""# ======== @L@: a progressive list of @E@ (@TX@) ========
# the Data mirror of element (s, e)
def ND_@L@(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +s: U32, +e: U32) -> @MB@: RT2.fz_@E@_bx(@TX@.OBJE(d, t, x, off, s, e))

# the value RV writes after element i: element i + 1
def NV_@L@(+i: U32, +m: U32, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> @MB@:
  ND_@L@(d, t, x, off, @TX@.WJ(t, x, i), @TX@.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1)))

def FT_@L@(k: Nat, +i: U32, +m: U32, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +dd: Nat, +T: FD.array__Tree<@MB@>, +u: @MB@) -> FD.array__Tree<@MB@>:
  match k:
    case 0n: FD.array__upd(@MB@, dd, T, U32.to_nat(i), u)
    case 1n+q: FT_@L@(q, U32.add(i, 1), m, d, t, x, off, len, dd, FD.array__upd(@MB@, dd, T, U32.to_nat(i), u), NV_@L@(i, m, d, t, x, off, len))

def pfFT_@L@(k: Nat, +i: U32, +m: U32, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +dd: Nat, +T: FD.array__Tree<@MB@>, +u: @MB@,
    +pf: {FD.array__perfect(@MB@, dd, T) == True{} : Bool}) -> {FD.array__perfect(@MB@, dd, FT_@L@(k, i, m, d, t, x, off, len, dd, T, u)) == True{} : Bool}:
  match k:
    case 0n: FD.array__upd_perfect(@MB@, dd, T, U32.to_nat(i), u, pf)
    case 1n+ +q: pfFT_@L@(q, U32.add(i, 1), m, d, t, x, off, len, dd, FD.array__upd(@MB@, dd, T, U32.to_nat(i), u), NV_@L@(i, m, d, t, x, off, len), FD.array__upd_perfect(@MB@, dd, T, U32.to_nat(i), u, pf))

# the empty array is am of the empty tree
def fillam_@L@(+c: Nat) -> {@LD@.@L@_fill(c) == RT2.am_@L@(FD.array__trep(@MB@, c, RT2.MNone{})) : Array<@BX@>}:
  match c:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Array<@BX@>, @LD@.@L@_fill(p), RT2.am_@L@(FD.array__trep(@MB@, p, RT2.MNone{})), fillam_@L@(p)) :
        {ANode{_, _} == ANode{RT2.am_@L@(FD.array__trep(@MB@, p, RT2.MNone{})), RT2.am_@L@(FD.array__trep(@MB@, p, RT2.MNone{}))} : Array<@BX@>}
      {==}

# an element whose check passed is th_bx of its mirror, and views as its window's value
def eqE_@L@(@WP@, +s: U32, +e: U32, +h: {@TX@.EE(True{}, t, x, off, len, s, e) == True{} : Bool})
    -> {@TX@.OBJE(d, t, x, off, s, e) == RT2.th_@E@_bx(ND_@L@(d, t, x, off, s, e)) : @BX@}:
  Equal.cong(@ETY@, @BX@, z => O.BSome{z, O.BNone{}}, @YW@.OBJw(d, t, Nat.add(U32.to_nat(s), x), U32.add(off, s), U32.sub(e, s)), RT2.th_@E@(RT2.fz_@E@(@YW@.OBJw(d, t, Nat.add(U32.to_nat(s), x), U32.add(off, s), U32.sub(e, s)))),
    Equal.sym(@ETY@, RT2.th_@E@(RT2.fz_@E@(@YW@.OBJw(d, t, Nat.add(U32.to_nat(s), x), U32.add(off, s), U32.sub(e, s)))), @YW@.OBJw(d, t, Nat.add(U32.to_nat(s), x), U32.add(off, s), U32.sub(e, s)), tf_@E@(@EA@)))

def elv_@L@(@WP@, +s: U32, +e: U32, +h: {@TX@.EE(True{}, t, x, off, len, s, e) == True{} : Bool})
    -> {RT2.v_@E@_bx(RT2.th_@E@_bx(ND_@L@(d, t, x, off, s, e))) == @TX@.VE(t, x, s, e) : S.Value}:
  %Equal.sym(@ETY@, RT2.th_@E@(RT2.fz_@E@(@YW@.OBJw(d, t, Nat.add(U32.to_nat(s), x), U32.add(off, s), U32.sub(e, s)))), @YW@.OBJw(d, t, Nat.add(U32.to_nat(s), x), U32.add(off, s), U32.sub(e, s)), tf_@E@(@EA@)) :
    {RT2.v_@E@(_) == @TX@.VE(t, x, s, e) : S.Value}
  vw_@E@(@EA@)

def hx_at_@L@(+dd: Nat, +T: FD.array__Tree<@MB@>, +s: Nat, +pf: {FD.array__perfect(@MB@, dd, T) == True{} : Bool}, +hs: {Nat.is_lt(s, FD.spec_common__pow2(dd)) == True{} : Bool})
    -> {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, T), s) == Some{RT2.xat_@L@(FD.array__slots(@MB@, T), s)} : Maybe<&2, @MB@>}:
  RT2.nth_@L@(FD.array__slots(@MB@, T), s, FD.logic__subst(Nat, z => {Nat.is_lt(s, z) == True{} : Bool}, FD.spec_common__pow2(dd), FD.spec_common__length(@MB@, FD.array__slots(@MB@, T)),
    Equal.sym(Nat, FD.spec_common__length(@MB@, FD.array__slots(@MB@, T)), FD.spec_common__pow2(dd), FD.array__slots_length(@MB@, dd, T, pf)), hs))

# ---- the reader's chain of writes is am of FT ----
def rvF_@L@(k: Nat, +i: U32, +m: U32, @WP@, +dd: Nat, +T: FD.array__Tree<@MB@>, +u: @MB@,
    +pfT: {FD.array__perfect(@MB@, dd, T) == True{} : Bool}, +hdd: {Nat.is_lt(dd, 32n) == True{} : Bool}, +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dd)) == True{} : Bool},
    +inv: {Nat.add(U32.to_nat(i), 1n+k) == U32.to_nat(m) : Nat}, +hE: {@TX@.EV(k, i, m, t, x, off, len, True{}, @TX@.WJ(t, x, i)) == True{} : Bool})
    -> {@TX@.RV(k, i, m, d, t, x, off, len, RT2.am_@L@(T), RT2.th_@E@_bx(u)) == RT2.am_@L@(FT_@L@(k, i, m, d, t, x, off, len, dd, T, u)) : Array<@BX@>}:
  match k:
    case 0n:
      +hi = hiq(i, 0n, m, dd, inv, hm)
      RT2.amset_@L@(dd, T, i, u, RT2.xat_@L@(FD.array__slots(@MB@, T), U32.to_nat(i)), hdd, hi, hx_at_@L@(dd, T, U32.to_nat(i), pfT, hi), pfT)
    case 1n+ +q:
      +hi = hiq(i, 1n+q, m, dd, inv, hm)
      +nb = @TX@.NX(U32.is_eq(U32.add(i, 2), m), t, x, len, U32.add(i, 1))
      +hc = @TX@.ev_ok(q, U32.add(i, 1), m, t, x, off, len, @TX@.EE(True{}, t, x, off, len, @TX@.WJ(t, x, i), nb), nb, hE)
      %Equal.sym(Array<@BX@>, Array.set(@BX@, RT2.am_@L@(T), i, RT2.th_@E@_bx(u)), RT2.am_@L@(FD.array__upd(@MB@, dd, T, U32.to_nat(i), u)),
          RT2.amset_@L@(dd, T, i, u, RT2.xat_@L@(FD.array__slots(@MB@, T), U32.to_nat(i)), hdd, hi, hx_at_@L@(dd, T, U32.to_nat(i), pfT, hi), pfT)) :
        {@TX@.RV(q, U32.add(i, 1), m, d, t, x, off, len, _, @TX@.OBJE(d, t, x, off, @TX@.WJ(t, x, i), nb)) == RT2.am_@L@(FT_@L@(1n+q, i, m, d, t, x, off, len, dd, T, u)) : Array<@BX@>}
      %Equal.sym(@BX@, @TX@.OBJE(d, t, x, off, @TX@.WJ(t, x, i), nb), RT2.th_@E@_bx(NV_@L@(i, m, d, t, x, off, len)), eqE_@L@(d, t, x, off, len, eo, hd, hw, pf, @TX@.WJ(t, x, i), nb, hc)) :
        {@TX@.RV(q, U32.add(i, 1), m, d, t, x, off, len, RT2.am_@L@(FD.array__upd(@MB@, dd, T, U32.to_nat(i), u)), _) == RT2.am_@L@(FT_@L@(1n+q, i, m, d, t, x, off, len, dd, T, u)) : Array<@BX@>}
      rvF_@L@(q, U32.add(i, 1), m, d, t, x, off, len, eo, hd, hw, pf, dd, FD.array__upd(@MB@, dd, T, U32.to_nat(i), u), NV_@L@(i, m, d, t, x, off, len), FD.array__upd_perfect(@MB@, dd, T, U32.to_nat(i), u, pfT), hdd, hm,
        inv1(i, q, m, inv), @TX@.he_nx(q, i, m, t, x, off, len, inv, hE))

# ---- the elements of FT ----
def lemU_@L@(+j: Nat, +i: Nat, +dd: Nat, +D: FD.array__Tree<@MB@>, +v: @MB@, +pf: {FD.array__perfect(@MB@, dd, D) == True{} : Bool},
    +hj: {Nat.is_lt(j, FD.spec_common__pow2(dd)) == True{} : Bool}, +ne: {Nat.is_eq(j, i) == False{} : Bool})
    -> {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FD.array__upd(@MB@, dd, D, j, v)), i) == FD.spec_common__nth(@MB@, FD.array__slots(@MB@, D), i) : Maybe<&2, @MB@>}:
  %Equal.sym(List<&2, @MB@>, FD.array__slots(@MB@, FD.array__upd(@MB@, dd, D, j, v)), FD.spec_common__update(@MB@, FD.array__slots(@MB@, D), j, v), FD.array__upd_slots(@MB@, dd, D, j, v, hj, pf)) :
    {FD.spec_common__nth(@MB@, _, i) == FD.spec_common__nth(@MB@, FD.array__slots(@MB@, D), i) : Maybe<&2, @MB@>}
  FD.list__nth_update_other(@MB@, FD.array__slots(@MB@, D), j, i, v, ne)

def lemS0_@L@(+j: Nat, +dd: Nat, +D: FD.array__Tree<@MB@>, +v: @MB@, +pf: {FD.array__perfect(@MB@, dd, D) == True{} : Bool},
    +hj: {Nat.is_lt(j, FD.spec_common__pow2(dd)) == True{} : Bool})
    -> {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FD.array__upd(@MB@, dd, D, j, v)), j) == Some{v} : Maybe<&2, @MB@>}:
  +hl = FD.logic__subst(Nat, z => {Nat.is_lt(j, z) == True{} : Bool}, FD.spec_common__pow2(dd), FD.spec_common__length(@MB@, FD.array__slots(@MB@, D)),
    Equal.sym(Nat, FD.spec_common__length(@MB@, FD.array__slots(@MB@, D)), FD.spec_common__pow2(dd), FD.array__slots_length(@MB@, dd, D, pf)), hj)
  %Equal.sym(List<&2, @MB@>, FD.array__slots(@MB@, FD.array__upd(@MB@, dd, D, j, v)), FD.spec_common__update(@MB@, FD.array__slots(@MB@, D), j, v), FD.array__upd_slots(@MB@, dd, D, j, v, hj, pf)) :
    {FD.spec_common__nth(@MB@, _, j) == Some{v} : Maybe<&2, @MB@>}
  FD.list__nth_update_same(@MB@, FD.array__slots(@MB@, D), j, v, hl)

def lemB_@L@(q: Nat, +i: U32, +s: Nat, +m: U32, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +dd: Nat, +D: FD.array__Tree<@MB@>, +u: @MB@,
    +pf: {FD.array__perfect(@MB@, dd, D) == True{} : Bool}, +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dd)) == True{} : Bool},
    +inv: {Nat.add(U32.to_nat(i), 1n+q) == U32.to_nat(m) : Nat}, +hs: {Nat.is_lt(s, U32.to_nat(i)) == True{} : Bool})
    -> {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FT_@L@(q, i, m, d, t, x, off, len, dd, D, u)), s) == FD.spec_common__nth(@MB@, FD.array__slots(@MB@, D), s) : Maybe<&2, @MB@>}:
  match q:
    case 0n: lemU_@L@(U32.to_nat(i), s, dd, D, u, pf, hiq(i, 0n, m, dd, inv, hm), isne(s, U32.to_nat(i), hs))
    case 1n+ +p:
      +D1 = FD.array__upd(@MB@, dd, D, U32.to_nat(i), u)
      Equal.trans(Maybe<&2, @MB@>, FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FT_@L@(p, U32.add(i, 1), m, d, t, x, off, len, dd, D1, NV_@L@(i, m, d, t, x, off, len))), s),
        FD.spec_common__nth(@MB@, FD.array__slots(@MB@, D1), s), FD.spec_common__nth(@MB@, FD.array__slots(@MB@, D), s),
        lemB_@L@(p, U32.add(i, 1), s, m, d, t, x, off, len, dd, D1, NV_@L@(i, m, d, t, x, off, len), FD.array__upd_perfect(@MB@, dd, D, U32.to_nat(i), u, pf), hm, inv1(i, p, m, inv), lts(i, p, m, s, inv, hs)),
        lemU_@L@(U32.to_nat(i), s, dd, D, u, pf, hiq(i, 1n+p, m, dd, inv, hm), isne(s, U32.to_nat(i), hs)))

def lemV_@L@(q: Nat, +i: U32, +m: U32, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +dd: Nat, +D: FD.array__Tree<@MB@>, +u: @MB@,
    +pf: {FD.array__perfect(@MB@, dd, D) == True{} : Bool}, +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dd)) == True{} : Bool},
    +inv: {Nat.add(U32.to_nat(i), 1n+q) == U32.to_nat(m) : Nat})
    -> {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FT_@L@(q, i, m, d, t, x, off, len, dd, D, u)), U32.to_nat(i)) == Some{u} : Maybe<&2, @MB@>}:
  match q:
    case 0n: lemS0_@L@(U32.to_nat(i), dd, D, u, pf, hiq(i, 0n, m, dd, inv, hm))
    case 1n+ +p:
      +D1 = FD.array__upd(@MB@, dd, D, U32.to_nat(i), u)
      Equal.trans(Maybe<&2, @MB@>, FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FT_@L@(p, U32.add(i, 1), m, d, t, x, off, len, dd, D1, NV_@L@(i, m, d, t, x, off, len))), U32.to_nat(i)),
        FD.spec_common__nth(@MB@, FD.array__slots(@MB@, D1), U32.to_nat(i)), Some{u},
        lemB_@L@(p, U32.add(i, 1), U32.to_nat(i), m, d, t, x, off, len, dd, D1, NV_@L@(i, m, d, t, x, off, len), FD.array__upd_perfect(@MB@, dd, D, U32.to_nat(i), u, pf), hm, inv1(i, p, m, inv),
          FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(i), z) == True{} : Bool}, 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1(i, p, m, inv)),
            FD.nat__lt_succ(U32.to_nat(i)))),
        lemS0_@L@(U32.to_nat(i), dd, D, u, pf, hiq(i, 1n+p, m, dd, inv, hm)))

def stepN_@L@(+p: Nat, +i: U32, +c: U32, +m: U32, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +dd: Nat, +D: FD.array__Tree<@MB@>, +u: @MB@,
    +pf: {FD.array__perfect(@MB@, dd, D) == True{} : Bool}, +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dd)) == True{} : Bool},
    +inv: {Nat.add(U32.to_nat(i), 2n+p) == U32.to_nat(m) : Nat}, +hic: {Nat.is_le(U32.to_nat(i), U32.to_nat(c)) == True{} : Bool}, +b: Bool, +eb: {Nat.is_eq(U32.to_nat(i), U32.to_nat(c)) == b : Bool},
    ih: @+h: {Nat.is_le(U32.to_nat(U32.add(i, 1)), U32.to_nat(c)) == True{} : Bool} -> {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FT_@L@(p, U32.add(i, 1), m, d, t, x, off, len, dd, FD.array__upd(@MB@, dd, D, U32.to_nat(i), u), NV_@L@(i, m, d, t, x, off, len))), 1n+U32.to_nat(c)) == Some{NV_@L@(c, m, d, t, x, off, len)} : Maybe<&2, @MB@>})
    -> {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FT_@L@(1n+p, i, m, d, t, x, off, len, dd, D, u)), 1n+U32.to_nat(c)) == Some{NV_@L@(c, m, d, t, x, off, len)} : Maybe<&2, @MB@>}:
  match b:
    case True{}:
      +ec = FD.u32__injective(i, c, FD.nat__eq_from_is_eq(U32.to_nat(i), U32.to_nat(c), eb))
      %ec : {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FT_@L@(1n+p, i, m, d, t, x, off, len, dd, D, u)), 1n+U32.to_nat(_)) == Some{NV_@L@(_, m, d, t, x, off, len)} : Maybe<&2, @MB@>}
      %e1(i, p, m, inv) : {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FT_@L@(p, U32.add(i, 1), m, d, t, x, off, len, dd, FD.array__upd(@MB@, dd, D, U32.to_nat(i), u), NV_@L@(i, m, d, t, x, off, len))), _) == Some{NV_@L@(i, m, d, t, x, off, len)} : Maybe<&2, @MB@>}
      lemV_@L@(p, U32.add(i, 1), m, d, t, x, off, len, dd, FD.array__upd(@MB@, dd, D, U32.to_nat(i), u), NV_@L@(i, m, d, t, x, off, len), FD.array__upd_perfect(@MB@, dd, D, U32.to_nat(i), u, pf), hm, inv1(i, p, m, inv))
    case False{}:
      +hlt = FD.nat__lt_or_eq(U32.to_nat(i), U32.to_nat(c), hic, eb)
      ih(FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(c)) == True{} : Bool}, 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1(i, p, m, inv)),
        FD.nat__lt_succ_le_succ(U32.to_nat(i), U32.to_nat(c), hlt)))

def lemN_@L@(q: Nat, +i: U32, +c: U32, +m: U32, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +dd: Nat, +D: FD.array__Tree<@MB@>, +u: @MB@,
    +pf: {FD.array__perfect(@MB@, dd, D) == True{} : Bool}, +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dd)) == True{} : Bool},
    +inv: {Nat.add(U32.to_nat(i), 1n+q) == U32.to_nat(m) : Nat}, +hic: {Nat.is_le(U32.to_nat(i), U32.to_nat(c)) == True{} : Bool},
    +hcq: {Nat.is_lt(U32.to_nat(c), Nat.add(U32.to_nat(i), q)) == True{} : Bool})
    -> {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FT_@L@(q, i, m, d, t, x, off, len, dd, D, u)), 1n+U32.to_nat(c)) == Some{NV_@L@(c, m, d, t, x, off, len)} : Maybe<&2, @MB@>}:
  match q:
    case 0n:
      +h0 = FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(c), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 0n), U32.to_nat(i), FD.nat__add_zero(U32.to_nat(i)), hcq)
      +hcc = FD.nat__lt_le_trans(U32.to_nat(c), U32.to_nat(i), U32.to_nat(c), h0, hic)
      Empty.absurd({FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FT_@L@(0n, i, m, d, t, x, off, len, dd, D, u)), 1n+U32.to_nat(c)) == Some{NV_@L@(c, m, d, t, x, off, len)} : Maybe<&2, @MB@>},
        FD.logic__false_true(Equal.trans(Bool, False{}, Nat.is_lt(U32.to_nat(c), U32.to_nat(c)), True{}, Equal.sym(Bool, Nat.is_lt(U32.to_nat(c), U32.to_nat(c)), False{}, FD.nat__lt_irrefl(U32.to_nat(c))), hcc)))
    case 1n+ +p:
      +h2 = FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(c), z) == True{} : Bool}, Nat.add(U32.to_nat(i), 1n+p), 1n+Nat.add(U32.to_nat(i), p), FD.nat__add_succ(U32.to_nat(i), p), hcq)
      +h3 = FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(c), Nat.add(z, p)) == True{} : Bool}, 1n+U32.to_nat(i), U32.to_nat(U32.add(i, 1)), Equal.sym(Nat, U32.to_nat(U32.add(i, 1)), 1n+U32.to_nat(i), e1(i, p, m, inv)), h2)
      stepN_@L@(p, i, c, m, d, t, x, off, len, dd, D, u, pf, hm, inv, hic, Nat.is_eq(U32.to_nat(i), U32.to_nat(c)), {==}, h =>
        lemN_@L@(p, U32.add(i, 1), c, m, d, t, x, off, len, dd, FD.array__upd(@MB@, dd, D, U32.to_nat(i), u), NV_@L@(i, m, d, t, x, off, len), FD.array__upd_perfect(@MB@, dd, D, U32.to_nat(i), u, pf), hm, inv1(i, p, m, inv), h, h3))

def sv_@L@(m: Maybe<&2, @MB@>, +z: @MB@) -> @MB@:
  match m:
    case None{}: z
    case Some{+y}: y

def xat_of_@L@(+dd: Nat, +T: FD.array__Tree<@MB@>, +s: Nat, +v: @MB@, +pf: {FD.array__perfect(@MB@, dd, T) == True{} : Bool}, +hs: {Nat.is_lt(s, FD.spec_common__pow2(dd)) == True{} : Bool},
    +h: {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, T), s) == Some{v} : Maybe<&2, @MB@>}) -> {RT2.xat_@L@(FD.array__slots(@MB@, T), s) == v : @MB@}:
  Equal.cong(Maybe<&2, @MB@>, @MB@, w => sv_@L@(w, v), Some{RT2.xat_@L@(FD.array__slots(@MB@, T), s)}, Some{v},
    Equal.trans(Maybe<&2, @MB@>, Some{RT2.xat_@L@(FD.array__slots(@MB@, T), s)}, FD.spec_common__nth(@MB@, FD.array__slots(@MB@, T), s), Some{v},
      Equal.sym(Maybe<&2, @MB@>, FD.spec_common__nth(@MB@, FD.array__slots(@MB@, T), s), Some{RT2.xat_@L@(FD.array__slots(@MB@, T), s)}, hx_at_@L@(dd, T, s, pf, hs)), h))

# elements 1 + c, 1 + c + 1, ... (k of them) of the final tree view as the window's items
def xiW_@L@(k: Nat, +c: U32, +s: Nat, +m: U32, @WP@, +dd: Nat, +K: Nat, +T0: FD.array__Tree<@MB@>, +u0: @MB@,
    +pf0: {FD.array__perfect(@MB@, dd, T0) == True{} : Bool}, +hm: {Nat.is_le(U32.to_nat(m), FD.spec_common__pow2(dd)) == True{} : Bool},
    +invK: {Nat.add(U32.to_nat(0), 1n+K) == U32.to_nat(m) : Nat}, +es: {1n+U32.to_nat(c) == s : Nat}, +invc: {Nat.add(U32.to_nat(c), 1n+k) == U32.to_nat(m) : Nat},
    +hE: {@TX@.EV(k, c, m, t, x, off, len, True{}, @TX@.WJ(t, x, c)) == True{} : Bool})
    -> {RT2.xi_@L@(k, FD.array__slots(@MB@, FT_@L@(K, 0, m, d, t, x, off, len, dd, T0, u0)), s) == @TX@.VI(k, c, m, t, x, len) : S.Value}:
  match k:
    case 0n: {==}
    case 1n+ +p:
      +FK = FT_@L@(K, 0, m, d, t, x, off, len, dd, T0, u0)
      +eK = FD.nat__succ_inj(Nat.add(U32.to_nat(c), 1n+p), K, Equal.trans(Nat, 1n+Nat.add(U32.to_nat(c), 1n+p), Nat.add(U32.to_nat(c), 2n+p), 1n+K,
        Equal.sym(Nat, Nat.add(U32.to_nat(c), 2n+p), 1n+Nat.add(U32.to_nat(c), 1n+p), FD.nat__add_succ(U32.to_nat(c), 1n+p)), Equal.trans(Nat, Nat.add(U32.to_nat(c), 2n+p), U32.to_nat(m), 1n+K, invc, Equal.sym(Nat, 1n+K, U32.to_nat(m), invK))))
      +hcK = FD.logic__subst(Nat, z => {Nat.is_lt(U32.to_nat(c), z) == True{} : Bool}, 1n+Nat.add(U32.to_nat(c), p), K,
        Equal.trans(Nat, 1n+Nat.add(U32.to_nat(c), p), Nat.add(U32.to_nat(c), 1n+p), K, Equal.sym(Nat, Nat.add(U32.to_nat(c), 1n+p), 1n+Nat.add(U32.to_nat(c), p), FD.nat__add_succ(U32.to_nat(c), p)), eK),
        FD.nat__le_lt_trans(U32.to_nat(c), Nat.add(U32.to_nat(c), p), 1n+Nat.add(U32.to_nat(c), p), FD.nat__le_add_right(U32.to_nat(c), p), FD.nat__lt_succ(Nat.add(U32.to_nat(c), p))))
      +hK = FD.logic__subst(Nat, z => {Nat.is_le(z, FD.spec_common__pow2(dd)) == True{} : Bool}, U32.to_nat(m), 1n+K, Equal.sym(Nat, 1n+K, U32.to_nat(m), invK), hm)
      +hs = FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(dd)) == True{} : Bool}, 1n+U32.to_nat(c), s, es, FD.nat__lt_le_trans(1n+U32.to_nat(c), 1n+K, FD.spec_common__pow2(dd), hcK, hK))
      +en = FD.logic__subst(Nat, z => {FD.spec_common__nth(@MB@, FD.array__slots(@MB@, FK), z) == Some{NV_@L@(c, m, d, t, x, off, len)} : Maybe<&2, @MB@>}, 1n+U32.to_nat(c), s, es,
        lemN_@L@(K, 0, c, m, d, t, x, off, len, dd, T0, u0, pf0, hm, invK, Order.zero_le(U32.to_nat(c)), hcK))
      +ex = xat_of_@L@(dd, FK, s, NV_@L@(c, m, d, t, x, off, len), pfFT_@L@(K, 0, m, d, t, x, off, len, dd, T0, u0, pf0), hs, en)
      +nb = @TX@.NX(U32.is_eq(U32.add(c, 2), m), t, x, len, U32.add(c, 1))
      +hc = @TX@.ev_ok(p, U32.add(c, 1), m, t, x, off, len, @TX@.EE(True{}, t, x, off, len, @TX@.WJ(t, x, c), nb), nb, hE)
      +es1 = Equal.cong(Nat, Nat, z => 1n+z, U32.to_nat(U32.add(c, 1)), s, Equal.trans(Nat, U32.to_nat(U32.add(c, 1)), 1n+U32.to_nat(c), s, e1(c, p, m, invc), es))
      %Equal.sym(@MB@, RT2.xat_@L@(FD.array__slots(@MB@, FK), s), NV_@L@(c, m, d, t, x, off, len), ex) :
        {S.Items{RT2.v_@E@_bx(RT2.th_@E@_bx(_)), RT2.xi_@L@(p, FD.array__slots(@MB@, FK), 1n+s)} == @TX@.VI(1n+p, c, m, t, x, len) : S.Value}
      %Equal.sym(S.Value, RT2.v_@E@_bx(RT2.th_@E@_bx(NV_@L@(c, m, d, t, x, off, len))), @TX@.VE(t, x, @TX@.WJ(t, x, c), nb), elv_@L@(d, t, x, off, len, eo, hd, hw, pf, @TX@.WJ(t, x, c), nb, hc)) :
        {S.Items{_, RT2.xi_@L@(p, FD.array__slots(@MB@, FK), 1n+s)} == @TX@.VI(1n+p, c, m, t, x, len) : S.Value}
      Equal.cong(S.Value, S.Value, z => S.Items{@TX@.VE(t, x, @TX@.WJ(t, x, c), nb), z}, RT2.xi_@L@(p, FD.array__slots(@MB@, FK), 1n+s), @TX@.VI(p, U32.add(c, 1), m, t, x, len),
        xiW_@L@(p, U32.add(c, 1), 1n+s, m, d, t, x, off, len, eo, hd, hw, pf, dd, K, T0, u0, pf0, hm, invK, es1, @TX@.inv_nx(p, c, m, invc), @TX@.he_nx(p, c, m, t, x, off, len, invc, hE)))

# ---- a nonempty window ----
def vtf_@L@(@WP@, +hc0: {@TX@.CF(@TX@.HC(@TX@.W0(t, x), len), t, x, off, len) == True{} : Bool})
    -> {RT2.xv_@L@(@TX@.RZ(False{}, d, t, x, off, len)) == @TX@.VZE(False{}, t, x, len) : S.Value}:
@PRE@
  +x0 = xat_of_@L@(dd, FK, 0n, u0, pfFT_@L@(k0, 0, N, d, t, x, off, len, dd, T0, u0, pf0), FD.nat__lt_le_trans(0n, U32.to_nat(N), FD.spec_common__pow2(dd), FD.nat__succ_le_lt(0n, U32.to_nat(N), h1), hm),
    lemV_@L@(k0, 0, N, d, t, x, off, len, dd, T0, u0, pf0, hm, inv))
  %Equal.sym(@BX@, @TX@.OBJE(d, t, x, off, f, @TX@.B1(t, x, len)), RT2.th_@E@_bx(u0), eqE_@L@(d, t, x, off, len, eo, hd, hw, pf, f, @TX@.B1(t, x, len), hc1)) :
    {S.Sequence{RT2.xi_@L@(U32.to_nat(N), FD.array__slots(@MB@, RT2.tfz_@L@(@TX@.RV(k0, 0, N, d, t, x, off, len, @LD@.@L@_fill(dd), _))), 0n)} == @TX@.VZE(False{}, t, x, len) : S.Value}
  %Equal.sym(Array<@BX@>, @LD@.@L@_fill(dd), RT2.am_@L@(T0), fillam_@L@(dd)) :
    {S.Sequence{RT2.xi_@L@(U32.to_nat(N), FD.array__slots(@MB@, RT2.tfz_@L@(@TX@.RV(k0, 0, N, d, t, x, off, len, _, RT2.th_@E@_bx(u0)))), 0n)} == @TX@.VZE(False{}, t, x, len) : S.Value}
  %Equal.sym(Array<@BX@>, @TX@.RV(k0, 0, N, d, t, x, off, len, RT2.am_@L@(T0), RT2.th_@E@_bx(u0)), RT2.am_@L@(FK), rvF_@L@(k0, 0, N, d, t, x, off, len, eo, hd, hw, pf, dd, T0, u0, pf0, hdd, hm, inv, hE0)) :
    {S.Sequence{RT2.xi_@L@(U32.to_nat(N), FD.array__slots(@MB@, RT2.tfz_@L@(_)), 0n)} == @TX@.VZE(False{}, t, x, len) : S.Value}
  %Equal.sym(FD.array__Tree<@MB@>, RT2.tfz_@L@(RT2.am_@L@(FK)), FK, RT2.tfzam_@L@(FK)) :
    {S.Sequence{RT2.xi_@L@(U32.to_nat(N), FD.array__slots(@MB@, _), 0n)} == @TX@.VZE(False{}, t, x, len) : S.Value}
  %inv : {S.Sequence{RT2.xi_@L@(_, FD.array__slots(@MB@, FK), 0n)} == @TX@.VZE(False{}, t, x, len) : S.Value}
  %Equal.sym(@MB@, RT2.xat_@L@(FD.array__slots(@MB@, FK), 0n), u0, x0) :
    {S.Sequence{S.Items{RT2.v_@E@_bx(RT2.th_@E@_bx(_)), RT2.xi_@L@(k0, FD.array__slots(@MB@, FK), 1n)}} == @TX@.VZE(False{}, t, x, len) : S.Value}
  %Equal.sym(S.Value, RT2.v_@E@_bx(RT2.th_@E@_bx(u0)), @TX@.VE(t, x, f, @TX@.B1(t, x, len)), elv_@L@(d, t, x, off, len, eo, hd, hw, pf, f, @TX@.B1(t, x, len), hc1)) :
    {S.Sequence{S.Items{_, RT2.xi_@L@(k0, FD.array__slots(@MB@, FK), 1n)}} == @TX@.VZE(False{}, t, x, len) : S.Value}
  Equal.cong(S.Value, S.Value, z => S.Sequence{S.Items{@TX@.VE(t, x, f, @TX@.B1(t, x, len)), z}}, RT2.xi_@L@(k0, FD.array__slots(@MB@, FK), 1n), @TX@.VI(k0, 0, N, t, x, len),
    xiW_@L@(k0, 0, 1n, N, d, t, x, off, len, eo, hd, hw, pf, dd, k0, T0, u0, pf0, hm, inv, {==}, inv, hE0))

def vtc_@L@(@WP@, +b: Bool, +hc: {@TX@.CZ(b, t, x, off, len) == True{} : Bool})
    -> {RT2.xv_@L@(@TX@.RZ(b, d, t, x, off, len)) == @TX@.VZE(b, t, x, len) : S.Value}:
  match b:
    case True{}: {==}
    case False{}: vtf_@L@(d, t, x, off, len, eo, hd, hw, pf, hc)

# the list a window reads views as the window's value, when the window lies in the buffer and its check passed
def vw_@L@(@WP@, +hc: {@TX@.CHKw(t, x, off, len) == True{} : Bool})
    -> {RT2.xv_@L@(@TX@.OBJw(d, t, x, off, len)) == @TX@.VALw(t, x, len) : S.Value}:
  vtc_@L@(d, t, x, off, len, eo, hd, hw, pf, U32.is_eq(len, 0), hc)

"""

GVL_TF = r"""# ... and it survives freezing then thawing
def tff_@L@(@WP@, +hc0: {@TX@.CF(@TX@.HC(@TX@.W0(t, x), len), t, x, off, len) == True{} : Bool})
    -> {RT2.th_@L@(RT2.fz_@L@(@TX@.RZ(False{}, d, t, x, off, len))) == @TX@.RZ(False{}, d, t, x, off, len) : @LTY@}:
@PRE@
  %Equal.sym(@BX@, @TX@.OBJE(d, t, x, off, f, @TX@.B1(t, x, len)), RT2.th_@E@_bx(u0), eqE_@L@(d, t, x, off, len, eo, hd, hw, pf, f, @TX@.B1(t, x, len), hc1)) :
    {@LD@.@L@_Seq{RT2.am_@L@(RT2.tfz_@L@(@TX@.RV(k0, 0, N, d, t, x, off, len, @LD@.@L@_fill(dd), _))), N} == @LD@.@L@_Seq{@TX@.RV(k0, 0, N, d, t, x, off, len, @LD@.@L@_fill(dd), _), N} : @LTY@}
  %Equal.sym(Array<@BX@>, @LD@.@L@_fill(dd), RT2.am_@L@(T0), fillam_@L@(dd)) :
    {@LD@.@L@_Seq{RT2.am_@L@(RT2.tfz_@L@(@TX@.RV(k0, 0, N, d, t, x, off, len, _, RT2.th_@E@_bx(u0)))), N} == @LD@.@L@_Seq{@TX@.RV(k0, 0, N, d, t, x, off, len, _, RT2.th_@E@_bx(u0)), N} : @LTY@}
  %Equal.sym(Array<@BX@>, @TX@.RV(k0, 0, N, d, t, x, off, len, RT2.am_@L@(T0), RT2.th_@E@_bx(u0)), RT2.am_@L@(FK), rvF_@L@(k0, 0, N, d, t, x, off, len, eo, hd, hw, pf, dd, T0, u0, pf0, hdd, hm, inv, hE0)) :
    {@LD@.@L@_Seq{RT2.am_@L@(RT2.tfz_@L@(_)), N} == @LD@.@L@_Seq{_, N} : @LTY@}
  %Equal.sym(FD.array__Tree<@MB@>, RT2.tfz_@L@(RT2.am_@L@(FK)), FK, RT2.tfzam_@L@(FK)) :
    {@LD@.@L@_Seq{RT2.am_@L@(_), N} == @LD@.@L@_Seq{RT2.am_@L@(FK), N} : @LTY@}
  {==}

def tfc_@L@(@WP@, +b: Bool, +hc: {@TX@.CZ(b, t, x, off, len) == True{} : Bool})
    -> {RT2.th_@L@(RT2.fz_@L@(@TX@.RZ(b, d, t, x, off, len))) == @TX@.RZ(b, d, t, x, off, len) : @LTY@}:
  match b:
    case True{}: {==}
    case False{}: tff_@L@(d, t, x, off, len, eo, hd, hw, pf, hc)

def tf_@L@(@WP@, +hc: {@TX@.CHKw(t, x, off, len) == True{} : Bool})
    -> {RT2.th_@L@(RT2.fz_@L@(@TX@.OBJw(d, t, x, off, len))) == @TX@.OBJw(d, t, x, off, len) : @LTY@}:
  tfc_@L@(d, t, x, off, len, eo, hd, hw, pf, U32.is_eq(len, 0), hc)
"""

GVL_PRE = r"""  +f = @TX@.W0(t, x)
  +N = @TX@.NN(t, x)
  +ec = @TX@.cf_ok(@TX@.HC(f, len), t, x, off, len, hc0)
  +hEV = FD.logic__subst(Bool, z => {@TX@.CF(z, t, x, off, len) == True{} : Bool}, @TX@.HC(f, len), True{}, ec, hc0)
  +hA = FD.logic__and_left(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), True{}), ec)
  +hB = FD.logic__and_right(Bool.and(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len)), Bool.and(U32.is_le(4, f), True{}), ec)
  +e3 = VVU.eqt(U32.and(f, 3), 0, FD.logic__and_left(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len), hA))
  +h4 = @TX@.ule(4, f, FD.logic__and_left(U32.is_le(4, f), True{}, hB))
  +hfl = @TX@.ule(f, len, FD.logic__and_right(U32.is_eq(U32.and(f, 3), 0), U32.is_le(f, len), hA))
  +ew = Equal.trans(Nat, U32.to_nat(f), Nat.add(A.quad(U32.to_nat(N)), U32.to_nat(U32.and(f, 3))), A.quad(U32.to_nat(N)), VC.split4(f),
    Equal.trans(Nat, Nat.add(A.quad(U32.to_nat(N)), U32.to_nat(U32.and(f, 3))), Nat.add(A.quad(U32.to_nat(N)), 0n), A.quad(U32.to_nat(N)),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(U32.to_nat(N)), z), U32.to_nat(U32.and(f, 3)), 0n, e3), FD.nat__add_zero(A.quad(U32.to_nat(N)))))
  +h1 = @TX@.quad_pos(U32.to_nat(N), FD.logic__subst(Nat, z => {Nat.is_le(4n, z) == True{} : Bool}, U32.to_nat(f), A.quad(U32.to_nat(N)), ew, h4))
  +es = FD.u32__sub_nat(N, 1, h1)
  +k0 = U32.to_nat(U32.sub(N, 1))
  +inv = Equal.trans(Nat, Nat.add(U32.to_nat(0), 1n+k0), 1n+Nat.sub(U32.to_nat(N), 1n), U32.to_nat(N),
    Equal.cong(Nat, Nat, z => 1n+z, k0, Nat.sub(U32.to_nat(N), 1n), es),
    FD.nat__sub_add(U32.to_nat(N), 1n, h1))
  +hc1 = @TX@.ev_ok(k0, 0, N, t, x, off, len, @TX@.EE(True{}, t, x, off, len, f, @TX@.B1(t, x, len)), @TX@.B1(t, x, len), hEV)
  +hE1 = FD.logic__subst(Bool, z => {@TX@.EV(k0, 0, N, t, x, off, len, z, @TX@.B1(t, x, len)) == True{} : Bool}, @TX@.EE(True{}, t, x, off, len, f, @TX@.B1(t, x, len)), True{}, hc1, hEV)
  +hE0 = @TX@.he0(t, x, off, len, U32.is_eq(1, N), {==}, hE1)
  +hNq = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(f), A.quad(U32.to_nat(N)), ew,
    FD.nat__le_trans(U32.to_nat(f), U32.to_nat(len), A.quad(VB.pw(d)), hfl, @TX@.hlen(d, x, len, hw)))
  +hN4 = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(N), z) == True{} : Bool}, VB.pw(d), O.pow2n(d), VD.s_pow2_eq(d), VC.quad_inv(U32.to_nat(N), VB.pw(d), hNq))
  +dd = B.words_depth(N)
  +hdd = FD.nat__le_lt_trans(dd, d, 32n, VD.wd_min(N, d, hN4), FD.nat__lt_trans(d, 28n, 32n, hd, {==}))
  +hm = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(N), z) == True{} : Bool}, O.pow2n(dd), FD.spec_common__pow2(dd), Equal.sym(Nat, FD.spec_common__pow2(dd), O.pow2n(dd), VD.s_pow2_eq(dd)),
    VD.wd_cover(N, d, FD.nat__lt_le(d, 32n, FD.nat__lt_trans(d, 28n, 32n, hd, {==})), hN4))
  +T0 = FD.array__trep(@MB@, dd, RT2.MNone{})
  +pf0 = FD.array__trep_perfect(@MB@, dd, RT2.MNone{})
  +u0 = ND_@L@(d, t, x, off, f, @TX@.B1(t, x, len))
  +FK = FT_@L@(k0, 0, N, d, t, x, off, len, dd, T0, u0)"""


def _gvl_ea(TX):
    """the element's window arguments (d, t, x, off, len, eo, hd, hw, pf, hc) from EE(True, .., s, e) == True (h)."""
    hab = f'{TX}.el_ab(t, x, off, len, s, e, h)'
    hb = f'{TX}.el_b(t, x, off, len, s, e, h)'
    return (f'd, t, Nat.add(U32.to_nat(s), x), U32.add(off, s), U32.sub(e, s), '
            f'{TX}.eoc(d, x, off, len, s, FD.nat__le_trans(U32.to_nat(s), U32.to_nat(e), U32.to_nat(len), {hab}, {hb}), eo, hd, hw), hd, '
            f'{TX}.hwab(d, x, len, s, e, {hab}, {hb}, hw), pf, {TX}.el_c(t, x, off, len, s, e, h)')


def gvl_text():
    body = [GVL_SHARED.replace('@WP@', GVL_WP)]
    imps = []
    for L, (mod, TX, E, ETY, LD) in GVL.items():
        imps.append(f'import ../proofs/obj/{mod}.bend as {TX}')
        LTY = f'{LD}.{L}_Seq'
        YW = f'{TX}.YW' if False else None
        yw = {'Gc465214E502': 'YW0', 'Gp66304057C3': 'YW1', 'pl_Gc465214E502': 'TA'}[E]
        txt = (GVL_PER + (GVL_TF if L in GVL_ELEM else '')).replace('@PRE@', GVL_PRE).replace('@EA@', _gvl_ea(TX)).replace('@WP@', GVL_WP)
        txt = (txt.replace('@MB@', f'RT2.MB<RT2.M_{E}>').replace('@BX@', f'O.Boxed<{ETY}>').replace('@ETY@', ETY).replace('@LTY@', LTY)
               .replace('@YW@', yw).replace('@TX@', TX).replace('@LD@', LD).replace('@L@', L).replace('@E@', E))
        body.append(txt)
    head = ['import Base', 'import ../src/obj.bend as O', 'import ../src/buffer.bend as B', 'import ../types/schema.bend as S',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/nat_order.bend as Order',
            'import ../proofs/obj/vbuf.bend as VB', 'import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vlist.bend as VLS',
            'import ../proofs/obj/vcopy.bend as VC', 'import ../proofs/obj/vua_ct.bend as UCT', 'import ../proofs/obj/big_vvlu.bend as VVU',
            'import ../proofs/obj/root_gtypes2.bend as RT2', 'import ../proofs/obj/vfx_u16.bend as FX16', 'import ../proofs/obj/vfx_u8.bend as FX8',
            'import ../proofs/obj/var_winx_Gc465214E502.bend as YW0', 'import ../proofs/obj/big_var_winx_Gp66304057C3.bend as YW1',
            'import ../proofs/obj/big_var_winp_pbits.bend as PBW', 'import ./e2e_gvt.bend as GVT', 'import ./e2e_gprog.bend as GP'] + imps
    head += [f'import ../types/{f}.bend as {a}' for a, f in GVL_TYPES]
    return '\n'.join(head) + '''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# Progressive lists of variable-size elements read at a byte window (the var_vlist windows): the reader's
# Array.set chain is RT2.am of tree updates FT_L (rvF_L; each element written is th_bx of its mirror, eqE_L);
# element 0 of FT_L is the first write (lemV_L), element 1 + c the write of element c (lemN_L); an element's view is
# its window's value (vw_E). vw_L: the list's root view is the window's value; tf_L: the list survives fz then th,
# so a list of such lists nests (pl_pl_Gc465214E502 over pl_Gc465214E502).

''' + '\n'.join(body)


SUPPORT_OUT['e2e_gvl.bend'] = gvl_text()


# ---- e2e_gcx: the progressive containers with list fields, read at a byte window ------------------------------
# GCX[X] = (window module, alias, [(field kind, child alias)]) with kinds: u8 (fixed at 0), l16 (List[uint16, N]),
# pb (progressive bits), pu8 / pu64 (progressive uint lists), rl (record list, e2e_grl), vl (e2e_gvl list)
GCX = {
    'Gc221EC01D83': ('var_winx_Gc221EC01D83', 'WPT', [('pu8', 'PU8'), ('pu64', 'PU64'), ('rl', 'RL4', 'pl_Gc4ED9619F50'), ('vl', 'TB', 'pl_pl_Gc465214E502')]),
    'Gp8A7851175B': ('big_var_winx_Gp8A7851175B', 'WPC', [('u8',), ('l16', 'L123'), ('pb', 'PBW'), ('pu64', 'PU64'), ('rl', 'RL4', 'pl_Gc4ED9619F50'),
                                                          ('vl', 'TB', 'pl_pl_Gc465214E502'), ('rl', 'RL1', 'l10_GpF350A3C486'), ('vl', 'TC', 'pl_Gp66304057C3')]),
}


def gcx_text():
    body = []
    imps = []
    for X, (mod, W, fields) in GCX.items():
        imps.append(f'import ../proofs/obj/{mod}.bend as {W}')
        nvar = sum(1 for f in fields if f[0] != 'u8')
        items = []
        k = 0
        for f in fields:
            kd = f[0]
            if kd == 'u8':
                items.append((f'RN.v_u8(FX8.OBJ(d, t, Nat.add(x, U32.to_nat(0))))', f'FX8.VAL(t, Nat.add(x, U32.to_nat(0)))', None))
                continue
            CH = f[1]
            ln = (k == nvar - 1)
            xj, fj, lj = f'{W}.XJ{k}(t, x)', f'{W}.FJ{k}(off, t, x)', f'{W}.LJ{k}(t, x' + (', len)' if ln else ')')
            win = f'd, t, {xj}, {fj}, {lj}'
            ja = f'{win}, {W}.eoJ{k}({GP_WA}), hd, {W}.hwJ{k}({GP_WA}), pf, {W}.itD{k}(t, x, off, len, h)'
            rhs = f'{CH}.VALw(t, {xj}, {lj})'
            if kd == 'pb':
                items.append((f'S.BitsValue{{BO.bview({CH}.OBJw({win}))}}', rhs,
                              f'Equal.cong(+List<Bool>, S.Value, z => S.BitsValue{{z}}, BO.bview({CH}.OBJw({win})), VBL.bl(UW.WX(t, {xj}, U32.to_nat({lj}))), GPB.pbv({ja}))'))
            elif kd == 'l16':
                items.append((f'PBF.vview2({CH}.OBJw({win}))', rhs, f'GP.lv_l123({ja})'))
            elif kd == 'pu8':
                items.append((f'PBF.vview1({CH}.OBJw({win}))', rhs, f'GP.pu8({ja})'))
            elif kd == 'pu64':
                items.append((f'UL.uview({CH}.OBJw({win}))', rhs, f'GP.pu64({ja})'))
            elif kd == 'rl':
                items.append((f'RT2.xv_{f[2]}({CH}.OBJw({win}))', rhs, f'GRL.vl_{f[2]}({ja})'))
            elif kd == 'vl':
                items.append((f'RT2.xv_{f[2]}({CH}.OBJw({win}))', rhs, f'GVL.vw_{f[2]}({ja})'))
            k += 1
        body.append(gp_view(X, W, items))
    head = ['import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/vbuf.bend as VB',
            'import ../proofs/obj/vua_win.bend as UW', 'import ../proofs/obj/vbitl.bend as VBL', 'import ../proofs/obj/packed_bytes.bend as PBF',
            'import ../proofs/obj/bitlist_obj.bend as BO', 'import ../proofs/obj/ulist_obj.bend as UL', 'import ../proofs/obj/root_gtypes2.bend as RT2',
            'import ../proofs/obj/root_gnames.bend as RN', 'import ../proofs/obj/vfx_u8.bend as FX8',
            'import ../proofs/obj/var_winx_l123_u16.bend as L123', 'import ../proofs/obj/big_var_winp_pbits.bend as PBW',
            'import ../proofs/obj/big_var_winp_u8.bend as PU8', 'import ../proofs/obj/big_var_winp_pl_u64.bend as PU64',
            'import ../proofs/obj/big_var_winx_pl_Gc4ED9619F50.bend as RL4', 'import ../proofs/obj/var_winx_l10_GpF350A3C486.bend as RL1',
            'import ../proofs/obj/big_vvl_pl_pl_Gc465214E502.bend as TB', 'import ../proofs/obj/big_vvl_pl_Gp66304057C3.bend as TC',
            'import ./e2e_gpb.bend as GPB', 'import ./e2e_gprog.bend as GP', 'import ./e2e_grl.bend as GRL', 'import ./e2e_gvl.bend as GVL'] + imps
    return '\n'.join(head) + '''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# The progressive containers with list fields read at a byte window (x, off, len): the object's root view is its
# codec value (vw_X), field by field: progressive uint lists (e2e_gprog), record lists (e2e_grl), lists of
# variable-size elements (e2e_gvl), a List[uint16, N] and progressive bits as in e2e_gprog.

''' + '\n'.join(body)


SUPPORT_OUT['e2e_gcx.bend'] = gcx_text()


# ---- e2e_encl: encode records from the root law's representation for list fields ------------------------------
ENCL_A = r"""# ---- the bound every unbounded list field takes: its bytes within 2^27 + 1 (P1) ----
def P1() -> Nat: Nat.add(VB.pw(27n), 1n)

# ---- pu8: a progressive list of uint8 field (big_encx_pl_u8) ----
def ok_pu8(+tt: FD.array__Tree<U32>, +n: U32, +sf: ER.SFT(tt, n, 28n)) -> {XU8.OK(XU8.MW{ER.LDEP(U32, tt), tt, n}) == True{} : Bool}:
  (+pf, +s1) = sf
  (+hdw, +s2) = s1
  (+hN, +htz) = s2
  FD.logic__and_intro(FD.array__perfect(U32, ER.LDEP(U32, tt), tt), Bool.and(Nat.is_lt(ER.LDEP(U32, tt), 28n), Bool.and(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(ER.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), True{}))), pf,
    FD.logic__and_intro(Nat.is_lt(ER.LDEP(U32, tt), 28n), Bool.and(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(ER.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), True{})), hdw,
    FD.logic__and_intro(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(ER.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), True{}), hN,
    FD.logic__and_intro(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), True{}, htz, {==}))))

def lv_pu8(+tt: FD.array__Tree<U32>, +n: U32) -> {PBF.vview1(O.Words{FD.array__thaw(U32, tt), n}) == PU8.VALw(tt, 0n, n) : S.Value}:
  +e1 = Equal.cong(+List<U32>, S.Value, z => S.Sequence{PBF.it1(U32.to_nat(n), z)}, WO.wview(O.Words{FD.array__thaw(U32, tt), n}), BL.WX0(tt, n), BL.wv0(tt, n))
  +e2 = Equal.cong(S.Value, S.Value, z => S.Sequence{z}, PBF.it1(U32.to_nat(n), BL.WX0(tt, n)), PBM.it1(U32.to_nat(n), BL.WX0(tt, n)), PL.it1eq(U32.to_nat(n), BL.WX0(tt, n)))
  Equal.trans(S.Value, PBF.vview1(O.Words{FD.array__thaw(U32, tt), n}), S.Sequence{PBF.it1(U32.to_nat(n), BL.WX0(tt, n))}, PU8.VALw(tt, 0n, n), e1, e2)

def LR_pu8(w: O.Words) -> Data:
  DK.Ex(XU8.MW, m => DK.P2({w == XU8.TH(m) : O.Words}, DK.P2({PBF.vview1(XU8.TH(m)) == XU8.VAL(m) : S.Value}, DK.P2({XU8.OK(m) == True{} : Bool}, {Nat.is_le(LY.LN(XU8.ENC(m)), P1()) == True{} : Bool}))))

# the premise of a byte-storage list field: its storage at depth below 28, its bytes within P1
def PW1(w: O.Words) -> Data: DK.P2(BL.sdk(w, 28n), {Nat.is_le(U32.to_nat(WO.len(w)), P1()) == True{} : Bool})

def lb2_pu8(-w: O.Words, +cw: DK.Ex(FD.array__Tree<U32>, t => DK.Ex(U32, n => {w == O.Words{FD.array__thaw(U32, t), n} : O.Words})), +hs: BL.sdk(w, 28n), +hl: {Nat.is_le(U32.to_nat(WO.len(w)), P1()) == True{} : Bool}) -> LR_pu8(w):
  (+tt, +c1) = cw
  (+n, +ew) = c1
  +hl2 = FD.logic__subst(O.Words, z => {Nat.is_le(U32.to_nat(WO.len(z)), P1()) == True{} : Bool}, w, O.Words{FD.array__thaw(U32, tt), n}, ew, hl)
  +hs2 = FD.logic__subst(O.Words, z => BL.sdk(z, 28n), w, O.Words{FD.array__thaw(U32, tt), n}, ew, hs)
  +hok = ok_pu8(tt, n, ER.sfk(tt, n, 28n, hs2))
  +ln = FD.logic__subst(Nat, z => {Nat.is_le(z, P1()) == True{} : Bool}, U32.to_nat(n), List.length(&2, U32, XU8.ENC(XU8.MW{ER.LDEP(U32, tt), tt, n})),
    Equal.sym(Nat, List.length(&2, U32, XU8.ENC(XU8.MW{ER.LDEP(U32, tt), tt, n})), U32.to_nat(n), XU8.eL(ER.LDEP(U32, tt), tt, n, hok)), hl2)
  (XU8.MW{ER.LDEP(U32, tt), tt, n}, (ew, (lv_pu8(tt, n), (hok, ln))))

def lb_pu8(-w: O.Words, +rep: LO.wfl(w), +hp: PW1(w)) -> LR_pu8(w):
  (+hs, +hl) = hp
  lb2_pu8(w, ER.cpw(w, rep), hs, hl)

# ---- pu64: a progressive list of uint64 field (big_encx_pl_u64) ----
def m4q(+j: Nat) -> {UR.m4(A.quad(j)) == 0n : Nat}:
  match j:
    case 0n: {==}
    case 1n+ +p: m4q(p)
def d4q(+j: Nat) -> {UR.d4(A.quad(j)) == j : Nat}:
  match j:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, UR.d4(A.quad(p)), p, d4q(p))

# the words read at 4 j, 4 j + 4, ... (m of them) are the tree's words from j
def rws0(m: Nat, +j: Nat, +dw: Nat, +t: FD.array__Tree<U32>, +pf: {FD.array__perfect(U32, dw, t) == True{} : Bool}, +h: {Nat.is_le(Nat.add(j, m), VB.pw(dw)) == True{} : Bool})
    -> {UR.RWS(m, t, A.quad(j)) == VS.wtake(m, VB.wdr(j, FD.array__slots(U32, t))) : List<&2, U32>}:
  match m:
    case 0n: {==}
    case 1n+ +p:
      +S = FD.array__slots(U32, t)
      +hj = FD.logic__subst(Nat, z => {Nat.is_lt(j, z) == True{} : Bool}, VB.pw(dw), VB.len(S), Equal.sym(Nat, VB.len(S), VB.pw(dw), FD.array__slots_length(U32, dw, t, pf)),
        FD.nat__lt_le_trans(j, Nat.add(j, 1n+p), VB.pw(dw), VTX.ltp(j, p), h))
      +h1 = FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw)) == True{} : Bool}, Nat.add(j, 1n+p), 1n+Nat.add(j, p), FD.nat__add_succ(j, p), h)
      %Equal.sym(List<&2, U32>, VB.wdr(j, S), Con{FD.flat__nthc(S, j), VB.wdr(1n+j, S)}, VB.wdr_eta(j, S, hj)) :
        {Con{UR.RWN(t, A.quad(j)), UR.RWS(p, t, A.quad(1n+j))} == VS.wtake(1n+p, _) : List<&2, U32>}
      %Equal.sym(Nat, UR.m4(A.quad(j)), 0n, m4q(j)) :
        {Con{UA.jn(_, VB.slot(t, UR.d4(A.quad(j))), VB.slot(t, 1n+UR.d4(A.quad(j)))), UR.RWS(p, t, A.quad(1n+j))} == Con{FD.flat__nthc(S, j), VS.wtake(p, VB.wdr(1n+j, S))} : List<&2, U32>}
      %Equal.sym(Nat, UR.d4(A.quad(j)), j, d4q(j)) :
        {Con{UA.jn(0n, VB.slot(t, _), VB.slot(t, 1n+_)), UR.RWS(p, t, A.quad(1n+j))} == Con{FD.flat__nthc(S, j), VS.wtake(p, VB.wdr(1n+j, S))} : List<&2, U32>}
      Equal.cong(List<&2, U32>, List<&2, U32>, z => Con{FD.flat__nthc(S, j), z}, UR.RWS(p, t, A.quad(1n+j)), VS.wtake(p, VB.wdr(1n+j, S)), rws0(p, 1n+j, dw, t, pf, h1))

def ok_pu64(+tt: FD.array__Tree<U32>, +n: U32, +sf: ER.SFT(tt, n, 28n), +c: Nat, +ex8: {U32.to_nat(n) == VS.x8(c) : Nat}, +emul: {U32.to_nat(n) == Nat.mul(c, 8n) : Nat})
    -> {XU64.OK(XU64.MW{ER.LDEP(U32, tt), tt, n}) == True{} : Bool}:
  (+pf, +s1) = sf
  (+hdw, +s2) = s1
  (+hN, +htz) = s2
  FD.logic__and_intro(FD.array__perfect(U32, ER.LDEP(U32, tt), tt), Bool.and(Nat.is_lt(ER.LDEP(U32, tt), 28n), Bool.and(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(ER.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(U32.is_eq(U32.and(n, 7), 0), PU64.CHKw(tt, 0n, 0, n))))), pf,
    FD.logic__and_intro(Nat.is_lt(ER.LDEP(U32, tt), 28n), Bool.and(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(ER.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(U32.is_eq(U32.and(n, 7), 0), PU64.CHKw(tt, 0n, 0, n)))), hdw,
    FD.logic__and_intro(Nat.is_le(U32.to_nat(n), A.quad(VB.pw(ER.LDEP(U32, tt)))), Bool.and(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(U32.is_eq(U32.and(n, 7), 0), PU64.CHKw(tt, 0n, 0, n))), hN,
    FD.logic__and_intro(O.tail_zero(U32.and(n, 3), VB.slot(tt, VY.QL(n))), Bool.and(U32.is_eq(U32.and(n, 7), 0), PU64.CHKw(tt, 0n, 0, n)), htz,
    FD.logic__and_intro(U32.is_eq(U32.and(n, 7), 0), PU64.CHKw(tt, 0n, 0, n), FD.u32alg__eq_true(U32.and(n, 7), 0, VEN.and7_x8(n, c, ex8)),
    VLS.whole_i1(n, 8, PU64.v8(), {==}, {==}, {==}, c, emul))))))

def cq8(+n: U32, +c: Nat, +emul: {U32.to_nat(n) == Nat.mul(c, 8n) : Nat}, wq: {U32.to_nat(U32.div(n, 8)) == c : Nat} & {U32.to_nat(U32.mod(n, 8)) == 0n : Nat}) -> {U32.to_nat(U32.div(n, 8)) == c : Nat}:
  (+cq, +cm) = wq
  cq

def lv_pu64(+dw: Nat, +tt: FD.array__Tree<U32>, +n: U32, +c: Nat, +pf: {FD.array__perfect(U32, dw, tt) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(dw))) == True{} : Bool},
    +ex8: {U32.to_nat(n) == VS.x8(c) : Nat}, +emul: {U32.to_nat(n) == Nat.mul(c, 8n) : Nat})
    -> {UL.uview(O.Words{FD.array__thaw(U32, tt), n}) == PU64.VALw(tt, 0n, n) : S.Value}:
  +S = FD.array__slots(U32, tt)
  +cq = cq8(n, c, emul, VU.whole_q(n, 8, c, emul, {==}, VU.div_u32(n, 8, PU64.v8(), {==}, {==}, {==})))
  +ecq = Equal.trans(Nat, U32.to_nat(U32.shrn(n, 3n)), VD.s_rng(3n, U32.to_nat(n)), c, VD.shrk(3n, n),
    Equal.trans(Nat, VD.s_rng(3n, U32.to_nat(n)), VD.s_rng(3n, VS.x8(c)), c, Equal.cong(Nat, Nat, z => VD.s_rng(3n, z), U32.to_nat(n), VS.x8(c), ex8), ULW.r8(c)))
  +eq8 = Equal.trans(Nat, U32.to_nat(n), Nat.mul(c, 8n), A.quad(Nat.double(c)), emul, VBG.mul8(c))
  +h2c = VC.quad_inv(Nat.double(c), VB.pw(dw), FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dw))) == True{} : Bool}, U32.to_nat(n), A.quad(Nat.double(c)), eq8, hN))
  +er = rws0(Nat.double(c), 0n, dw, tt, pf, h2c)
  %Equal.sym(Nat, U32.to_nat(U32.div(n, 8)), c, cq) : {UL.uview(O.Words{FD.array__thaw(U32, tt), n}) == S.Sequence{VS.uitems(_, UR.RWS(Nat.double(_), tt, 0n))} : S.Value}
  %Equal.sym(List<&2, U32>, UR.RWS(Nat.double(c), tt, 0n), VS.wtake(Nat.double(c), S), er) : {UL.uview(O.Words{FD.array__thaw(U32, tt), n}) == S.Sequence{VS.uitems(c, _)} : S.Value}
  Equal.trans(S.Value, UL.uview(O.Words{FD.array__thaw(U32, tt), n}), S.Sequence{VS.uitems(c, S)}, S.Sequence{VS.uitems(c, VS.wtake(Nat.double(c), S))},
    ULW.uvw(tt, n, c, ecq), Equal.cong(S.Value, S.Value, z => S.Sequence{z}, VS.uitems(c, S), VS.uitems(c, VS.wtake(Nat.double(c), S)), GP.ut(c, S)))

def LR_pu64(w: O.Words) -> Data:
  DK.Ex(XU64.MW, m => DK.P2({w == XU64.TH(m) : O.Words}, DK.P2({UL.uview(XU64.TH(m)) == XU64.VAL(m) : S.Value}, DK.P2({XU64.OK(m) == True{} : Bool}, {Nat.is_le(LY.LN(XU64.ENC(m)), P1()) == True{} : Bool}))))

def lb3_pu64(-w: O.Words, +tt: FD.array__Tree<U32>, +n: U32, +ew: {w == O.Words{FD.array__thaw(U32, tt), n} : O.Words}, +sf: ER.SFT(tt, n, 28n), +c: Nat,
    +ex8: {U32.to_nat(n) == VS.x8(c) : Nat}, +emul: {U32.to_nat(n) == Nat.mul(c, 8n) : Nat}, +hl2: {Nat.is_le(U32.to_nat(n), P1()) == True{} : Bool}) -> LR_pu64(w):
  (+pf, +s1) = sf
  (+hdw, +s2) = s1
  (+hN, +htz) = s2
  +hok = ok_pu64(tt, n, (pf, (hdw, (hN, htz))), c, ex8, emul)
  +ln = FD.logic__subst(Nat, z => {Nat.is_le(z, P1()) == True{} : Bool}, U32.to_nat(n), List.length(&2, U32, XU64.ENC(XU64.MW{ER.LDEP(U32, tt), tt, n})),
    Equal.sym(Nat, List.length(&2, U32, XU64.ENC(XU64.MW{ER.LDEP(U32, tt), tt, n})), U32.to_nat(n), XU64.eL(ER.LDEP(U32, tt), tt, n, hok)), hl2)
  (XU64.MW{ER.LDEP(U32, tt), tt, n}, (ew, (lv_pu64(ER.LDEP(U32, tt), tt, n, c, pf, hN, ex8, emul), (hok, ln))))

def lb2_pu64(-w: O.Words, +cw: DK.Ex(FD.array__Tree<U32>, t => DK.Ex(U32, n => {w == O.Words{FD.array__thaw(U32, t), n} : O.Words})), +hs: BL.sdk(w, 28n), +hl: {Nat.is_le(U32.to_nat(WO.len(w)), P1()) == True{} : Bool},
    +eN: {U32.to_nat(WO.len(w)) == O.e8(UL.ucnt(w)) : Nat}) -> LR_pu64(w):
  (+tt, +c1) = cw
  (+n, +ew) = c1
  +hl2 = FD.logic__subst(O.Words, z => {Nat.is_le(U32.to_nat(WO.len(z)), P1()) == True{} : Bool}, w, O.Words{FD.array__thaw(U32, tt), n}, ew, hl)
  +hs2 = FD.logic__subst(O.Words, z => BL.sdk(z, 28n), w, O.Words{FD.array__thaw(U32, tt), n}, ew, hs)
  +eN2 = FD.logic__subst(O.Words, z => {U32.to_nat(WO.len(z)) == O.e8(UL.ucnt(z)) : Nat}, w, O.Words{FD.array__thaw(U32, tt), n}, ew, eN)
  +c = UL.ucnt(O.Words{FD.array__thaw(U32, tt), n})
  +ex8 = Equal.trans(Nat, U32.to_nat(n), O.e8(c), VS.x8(c), eN2, Equal.sym(Nat, VS.x8(c), O.e8(c), ULW.x8e(c)))
  +emul = Equal.trans(Nat, U32.to_nat(n), VS.x8(c), Nat.mul(c, 8n), ex8, Equal.sym(Nat, Nat.mul(c, 8n), VS.x8(c), VC.x8_mul(c)))
  lb3_pu64(w, tt, n, ew, ER.sfk(tt, n, 28n, hs2), c, ex8, emul, hl2)

def lb_pu64(-w: O.Words, +rp: DK.P2(LO.wfl(w), {U32.to_nat(WO.len(w)) == O.e8(UL.ucnt(w)) : Nat}), +hp: PW1(w)) -> LR_pu64(w):
  (+wf, +eN) = rp
  (+hs, +hl) = hp
  lb2_pu64(w, ER.cpw(w, wf), hs, hl, eN)

# ---- a container's byte bound: closed terms, and k terms of at most P + 1 bytes each (k <= 7) ----
def KP(k: Nat, +P: Nat) -> Nat:
  match k:
    case 0n: 0n
    case 1n+q: Nat.add(P, KP(q, P))

# (a + b) + (c + d) == (a + d) + (c + b)
def sw4(+a: Nat, +b: Nat, +c: Nat, +d: Nat) -> {Nat.add(Nat.add(a, b), Nat.add(c, d)) == Nat.add(Nat.add(a, d), Nat.add(c, b)) : Nat}:
  Equal.trans(Nat, Nat.add(Nat.add(a, b), Nat.add(c, d)), Nat.add(a, Nat.add(b, Nat.add(c, d))), Nat.add(Nat.add(a, d), Nat.add(c, b)), FD.nat__add_assoc(a, b, Nat.add(c, d)),
    Equal.trans(Nat, Nat.add(a, Nat.add(b, Nat.add(c, d))), Nat.add(a, Nat.add(d, Nat.add(c, b))), Nat.add(Nat.add(a, d), Nat.add(c, b)),
      Equal.cong(Nat, Nat, z => Nat.add(a, z), Nat.add(b, Nat.add(c, d)), Nat.add(d, Nat.add(c, b)),
        Equal.trans(Nat, Nat.add(b, Nat.add(c, d)), Nat.add(c, Nat.add(b, d)), Nat.add(d, Nat.add(c, b)), FD.lru_nat_algebra__add_swap(b, c, d),
          Equal.trans(Nat, Nat.add(c, Nat.add(b, d)), Nat.add(c, Nat.add(d, b)), Nat.add(d, Nat.add(c, b)), Equal.cong(Nat, Nat, z => Nat.add(c, z), Nat.add(b, d), Nat.add(d, b), FD.nat__add_comm(b, d)),
            FD.lru_nat_algebra__add_swap(c, d, b)))),
      Equal.sym(Nat, Nat.add(Nat.add(a, d), Nat.add(c, b)), Nat.add(a, Nat.add(d, Nat.add(c, b))), FD.nat__add_assoc(a, d, Nat.add(c, b)))))

# a closed term of at most B bytes
def acc(+a: Nat, +x: Nat, +c: Nat, +B: Nat, +k: Nat, +P: Nat, +ha: {Nat.is_le(a, Nat.add(c, KP(k, P))) == True{} : Bool}, +hx: {Nat.is_le(x, B) == True{} : Bool})
    -> {Nat.is_le(Nat.add(a, x), Nat.add(Nat.add(c, B), KP(k, P))) == True{} : Bool}:
  +e = Equal.trans(Nat, Nat.add(Nat.add(c, KP(k, P)), B), Nat.add(c, Nat.add(KP(k, P), B)), Nat.add(Nat.add(c, B), KP(k, P)), FD.nat__add_assoc(c, KP(k, P), B),
    Equal.trans(Nat, Nat.add(c, Nat.add(KP(k, P), B)), Nat.add(c, Nat.add(B, KP(k, P))), Nat.add(Nat.add(c, B), KP(k, P)), Equal.cong(Nat, Nat, z => Nat.add(c, z), Nat.add(KP(k, P), B), Nat.add(B, KP(k, P)), FD.nat__add_comm(KP(k, P), B)),
      Equal.sym(Nat, Nat.add(Nat.add(c, B), KP(k, P)), Nat.add(c, Nat.add(B, KP(k, P))), FD.nat__add_assoc(c, B, KP(k, P)))))
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(a, x), z) == True{} : Bool}, Nat.add(Nat.add(c, KP(k, P)), B), Nat.add(Nat.add(c, B), KP(k, P)), e, ER.addle(a, x, Nat.add(c, KP(k, P)), B, ha, hx))

# a term of at most P + 1 bytes
def acu(+a: Nat, +x: Nat, +c: Nat, +k: Nat, +P: Nat, +ha: {Nat.is_le(a, Nat.add(c, KP(k, P))) == True{} : Bool}, +hx: {Nat.is_le(x, Nat.add(P, 1n)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(a, x), Nat.add(Nat.add(c, 1n), KP(1n+k, P))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(a, x), z) == True{} : Bool}, Nat.add(Nat.add(c, KP(k, P)), Nat.add(P, 1n)), Nat.add(Nat.add(c, 1n), Nat.add(P, KP(k, P))), sw4(c, KP(k, P), P, 1n),
    ER.addle(a, x, Nat.add(c, KP(k, P)), Nat.add(P, 1n), ha, hx))

def acz(+c: Nat, +P: Nat) -> {Nat.is_le(c, Nat.add(c, KP(0n, P))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(c, z) == True{} : Bool}, c, Nat.add(c, 0n), Equal.sym(Nat, Nat.add(c, 0n), c, FD.nat__add_zero(c)), FD.nat__le_refl(c))

def kpm(k: Nat, m: Nat, +P: Nat, +h: {Nat.is_le(k, m) == True{} : Bool}) -> {Nat.is_le(KP(k, P), KP(m, P)) == True{} : Bool}:
  match k m:
    case 0n _: Order.zero_le(KP(m, P))
    case 1n+ +p 0n: Empty.absurd({Nat.is_le(KP(1n+p, P), KP(0n, P)) == True{} : Bool}, FD.logic__false_true(h))
    case 1n+ +p 1n+ +q: Order.add_left(P, KP(p, P), KP(q, P), kpm(p, q, P, h))

def kpa(a: Nat, +b: Nat, +P: Nat) -> {KP(Nat.add(a, b), P) == Nat.add(KP(a, P), KP(b, P)) : Nat}:
  match a:
    case 0n: {==}
    case 1n+ +p:
      Equal.trans(Nat, Nat.add(P, KP(Nat.add(p, b), P)), Nat.add(P, Nat.add(KP(p, P), KP(b, P))), Nat.add(Nat.add(P, KP(p, P)), KP(b, P)),
        Equal.cong(Nat, Nat, z => Nat.add(P, z), KP(Nat.add(p, b), P), Nat.add(KP(p, P), KP(b, P)), kpa(p, b, P)),
        Equal.sym(Nat, Nat.add(Nat.add(P, KP(p, P)), KP(b, P)), Nat.add(P, Nat.add(KP(p, P), KP(b, P))), FD.nat__add_assoc(P, KP(p, P), KP(b, P))))

def dbl(x: Nat) -> {Nat.double(x) == Nat.add(x, x) : Nat}:
  match x:
    case 0n: {==}
    case 1n+ +p:
      Equal.trans(Nat, 2n+Nat.double(p), 2n+Nat.add(p, p), 1n+Nat.add(p, 1n+p), Equal.cong(Nat, Nat, z => 2n+z, Nat.double(p), Nat.add(p, p), dbl(p)),
        Equal.cong(Nat, Nat, z => 1n+z, 1n+Nat.add(p, p), Nat.add(p, 1n+p), Equal.sym(Nat, Nat.add(p, 1n+p), 1n+Nat.add(p, p), FD.nat__add_succ(p, p))))

def kpd(+k: Nat, +P: Nat, +y: Nat, +e: {KP(k, P) == y : Nat}) -> {KP(Nat.add(k, k), P) == Nat.double(y) : Nat}:
  Equal.trans(Nat, KP(Nat.add(k, k), P), Nat.add(KP(k, P), KP(k, P)), Nat.double(y), kpa(k, k, P),
    Equal.trans(Nat, Nat.add(KP(k, P), KP(k, P)), Nat.add(y, y), Nat.double(y), Equal.cong(Nat, Nat, z => Nat.add(z, z), KP(k, P), y, e), Equal.sym(Nat, Nat.double(y), Nat.add(y, y), dbl(y))))

def kp8(+P: Nat) -> {KP(8n, P) == A.quad(Nat.double(P)) : Nat}:
  +e1 = Equal.trans(Nat, KP(1n, P), Nat.add(P, 0n), P, {==}, FD.nat__add_zero(P))
  +e2 = kpd(1n, P, P, e1)
  +e4 = kpd(2n, P, Nat.double(P), e2)
  kpd(4n, P, Nat.double(Nat.double(P)), e4)

# the total within 2^30 = 8 P (P = 2^27): c <= P, at most 7 unbounded terms
def fin(+s: Nat, +c: Nat, +k: Nat, +P: Nat, +h: {Nat.is_le(s, Nat.add(c, KP(k, P))) == True{} : Bool}, +hc: {Nat.is_le(c, P) == True{} : Bool}, +hk: {Nat.is_le(k, 7n) == True{} : Bool})
    -> {Nat.is_le(s, A.quad(Nat.double(P))) == True{} : Bool}:
  FD.nat__le_trans(s, Nat.add(c, KP(k, P)), A.quad(Nat.double(P)), h,
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(c, KP(k, P)), z) == True{} : Bool}, KP(8n, P), A.quad(Nat.double(P)), kp8(P),
      ER.addle(c, KP(k, P), P, KP(7n, P), hc, kpm(k, 7n, P, hk))))
"""

# record lists: tag -> (EX file, EX alias, element def alias.type name, element tag, element encode alias, RS, field kinds, limit or None, list def alias)
ENCL_RL = {
    'pl_Gc4ED9619F50': ('big_encx_pl_Gc4ED9619F50', 'XR4', 'SmallTestStruct_d', 'Gc4ED9619F50', 'SmallTestStruct_e', 4, ['u16', 'u16'], None, 'proglist_SmallTestStruct_d'),
    'l10_GpF350A3C486': ('big_encx_l10_GpF350A3C486', 'XR1', 'ProgressiveSingleFieldContainerTestStruct_d', 'GpF350A3C486', 'ProgressiveSingleFieldContainerTestStruct_e', 1, ['u8'], 10, 'list_ProgressiveSingleFieldContainerTestStruct_10_d'),
}

ENCL_RL_SHARED = r"""# ---- record lists: shared ----
# r bytes per record, r <= 4: x records within 4 x bytes
def mq(+x: Nat, +r: Nat, +hr: {Nat.is_le(r, 4n) == True{} : Bool}) -> {Nat.is_le(Nat.mul(x, r), A.quad(x)) == True{} : Bool}:
  match x:
    case 0n: {==}
    case 1n+ +p: ER.addle(r, Nat.mul(p, r), 4n, A.quad(p), hr, mq(p, r, hr))

# i < 2^dw when i + 1 + q <= 2^dw
def ltq(+i: Nat, +q: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(i, 1n+q), P) == True{} : Bool}) -> {Nat.is_lt(i, P) == True{} : Bool}:
  FD.nat__lt_le_trans(i, Nat.add(i, 1n+q), P, VTX.ltp(i, q), h)
def nxq(+i: Nat, +q: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(i, 1n+q), P) == True{} : Bool}) -> {Nat.is_le(Nat.add(1n+i, q), P) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(i, 1n+q), 1n+Nat.add(i, q), FD.nat__add_succ(i, q), h)
"""

ENCL_RL_PER = r"""# ---- @T@: a list of @EN@ records (@RS@ bytes each), @X@ ----
# a record the root law represents is valid, and its view is the codec law's
def vrp_@T@(+o: @ED@.@EN@, +rp: RN.rp_@EN@(o)) -> {@EE@.@EN@_valid(o) == True{} : Bool}:
  match o:
    case @ED@.@EN@{@FV@}:
@VRPB@

def rvv_@T@(+o: @ED@.@EN@, +rp: RN.rp_@EN@(o)) -> {RN.v_@EN@(o) == @X@.RV_@EN@(o) : S.Value}:
  match o:
    case @ED@.@EN@{@FV@}:
@RVVB@

# record j of the tree is the root's element j
def elx_@T@(+A: FD.array__Tree<@ET@>, +dw: Nat, +j: Nat, +pf: {FD.array__perfect(@ET@, dw, A) == True{} : Bool}, +hj: {Nat.is_lt(j, FD.spec_common__pow2(dw)) == True{} : Bool})
    -> {@X@.EL(A, j) == RT2.xat_@T@(FD.array__slots(@ET@, A), j) : @ET@}:
  Equal.cong(Maybe<&2, @ET@>, @ET@, m => VRL.mget(@ET@, m, @ET@_default()), FD.spec_common__nth(@ET@, FD.array__slots(@ET@, A), j), Some{RT2.xat_@T@(FD.array__slots(@ET@, A), j)},
    RT2.nth_@T@(FD.array__slots(@ET@, A), j, FD.logic__subst(Nat, z => {Nat.is_lt(j, z) == True{} : Bool}, FD.spec_common__pow2(dw), FD.spec_common__length(@ET@, FD.array__slots(@ET@, A)),
      Equal.sym(Nat, FD.spec_common__length(@ET@, FD.array__slots(@ET@, A)), FD.spec_common__pow2(dw), FD.array__slots_length(@ET@, dw, A, pf)), hj)))

def vok_@T@(k: Nat, +A: FD.array__Tree<@ET@>, +i: Nat, +dw: Nat, +pf: {FD.array__perfect(@ET@, dw, A) == True{} : Bool},
    +er: RT2.ereps_@T@(k, FD.array__slots(@ET@, A), i), +hb: {Nat.is_le(Nat.add(i, k), FD.spec_common__pow2(dw)) == True{} : Bool}) -> {@X@.VOK(k, A, i) == True{} : Bool}:
  match k:
    case 0n: {==}
    case 1n+ +q:
      (+r0, +er1) = er
      +ex = elx_@T@(A, dw, i, pf, ltq(i, q, FD.spec_common__pow2(dw), hb))
      +hv = FD.logic__subst(@ET@, z => {@EE@.@EN@_valid(z) == True{} : Bool}, RT2.xat_@T@(FD.array__slots(@ET@, A), i), @X@.EL(A, i), Equal.sym(@ET@, @X@.EL(A, i), RT2.xat_@T@(FD.array__slots(@ET@, A), i), ex),
        vrp_@T@(RT2.xat_@T@(FD.array__slots(@ET@, A), i), r0))
      FD.logic__and_intro(@EE@.@EN@_valid(@X@.EL(A, i)), @X@.VOK(q, A, 1n+i), hv, vok_@T@(q, A, 1n+i, dw, pf, er1, nxq(i, q, FD.spec_common__pow2(dw), hb)))

def its_@T@(k: Nat, +A: FD.array__Tree<@ET@>, +i: Nat, +dw: Nat, +pf: {FD.array__perfect(@ET@, dw, A) == True{} : Bool},
    +er: RT2.ereps_@T@(k, FD.array__slots(@ET@, A), i), +hb: {Nat.is_le(Nat.add(i, k), FD.spec_common__pow2(dw)) == True{} : Bool})
    -> {RT2.xi_@T@(k, FD.array__slots(@ET@, A), i) == @X@.ITS(k, A, i) : S.Value}:
  match k:
    case 0n: {==}
    case 1n+ +q:
      (+r0, +er1) = er
      +xa = RT2.xat_@T@(FD.array__slots(@ET@, A), i)
      +ex = elx_@T@(A, dw, i, pf, ltq(i, q, FD.spec_common__pow2(dw), hb))
      %Equal.sym(@ET@, @X@.EL(A, i), xa, ex) : {S.Items{RN.v_@EN@(xa), RT2.xi_@T@(q, FD.array__slots(@ET@, A), 1n+i)} == S.Items{@X@.RV_@EN@(_), @X@.ITS(q, A, 1n+i)} : S.Value}
      %rvv_@T@(xa, r0) : {S.Items{RN.v_@EN@(xa), RT2.xi_@T@(q, FD.array__slots(@ET@, A), 1n+i)} == S.Items{_, @X@.ITS(q, A, 1n+i)} : S.Value}
      Equal.cong(S.Value, S.Value, z => S.Items{RN.v_@EN@(xa), z}, RT2.xi_@T@(q, FD.array__slots(@ET@, A), 1n+i), @X@.ITS(q, A, 1n+i), its_@T@(q, A, 1n+i, dw, pf, er1, nxq(i, q, FD.spec_common__pow2(dw), hb)))

def lrbs_@T@(k: Nat, +A: FD.array__Tree<@ET@>, +j: Nat) -> {LY.LN(@X@.RBS(k, A, j)) == Nat.mul(k, @RS@n) : Nat}:
  match k:
    case 0n: {==}
    case 1n+ +q:
      Equal.trans(Nat, LY.LN(@X@.RBS(1n+q, A, j)), Nat.add(LY.LN(@X@.RB_@EN@(@X@.EL(A, j))), LY.LN(@X@.RBS(q, A, 1n+j))), Nat.add(@RS@n, Nat.mul(q, @RS@n)),
        VRX.len_app(@X@.RB_@EN@(@X@.EL(A, j)), @X@.RBS(q, A, 1n+j)),
        Equal.trans(Nat, Nat.add(LY.LN(@X@.RB_@EN@(@X@.EL(A, j))), LY.LN(@X@.RBS(q, A, 1n+j))), Nat.add(@RS@n, LY.LN(@X@.RBS(q, A, 1n+j))), Nat.add(@RS@n, Nat.mul(q, @RS@n)),
          Equal.cong(Nat, Nat, z => Nat.add(z, LY.LN(@X@.RBS(q, A, 1n+j))), LY.LN(@X@.RB_@EN@(@X@.EL(A, j))), @RS@n, @X@.lenr_@EN@(@X@.EL(A, j))),
          Equal.cong(Nat, Nat, z => Nat.add(@RS@n, z), LY.LN(@X@.RBS(q, A, 1n+j)), Nat.mul(q, @RS@n), lrbs_@T@(q, A, 1n+j))))

def LRR_@T@(o: @LD@.@T@_Seq) -> Data:
  DK.Ex(@X@.MW, m => DK.P2({o == @X@.TH(m) : @LD@.@T@_Seq}, DK.P2({RT2.xv_@T@(@X@.TH(m)) == @X@.VAL(m) : S.Value}, DK.P2({@X@.OK(m) == True{} : Bool}, {Nat.is_le(LY.LN(@X@.ENC(m)), @BND@) == True{} : Bool}))))

# the premise: the records' tree at depth below 28@PDOC@
def PRL_@T@(o: @LD@.@T@_Seq) -> Data:
  match o:
    case @LD@.@T@_Seq{arr, +N}: @PRLB@

def rb2_@T@(-o: @LD@.@T@_Seq, +t: FD.array__Tree<@ET@>, +dw: Nat, +N: U32, +eo: {o == @LD@.@T@_Seq{FD.array__thaw(@ET@, t), N} : @LD@.@T@_Seq},
    +pf: {FD.array__perfect(@ET@, dw, t) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{} : Bool},
    +er: RT2.ereps_@T@(U32.to_nat(N), FD.array__slots(@ET@, t), 0n), @LIMP@+hp: PRL_@T@(@LD@.@T@_Seq{FD.array__thaw(@ET@, t), N})) -> LRR_@T@(o):
@HPD@
  +ed = Equal.trans(Nat, ER.LDEP(@ET@, FD.array__freeze(@ET@, FD.array__thaw(@ET@, t))), ER.LDEP(@ET@, t), dw,
    Equal.cong(FD.array__Tree<@ET@>, Nat, z => ER.LDEP(@ET@, z), FD.array__freeze(@ET@, FD.array__thaw(@ET@, t)), t, FD.array__freeze_thaw(@ET@, t)), ER.pdep(@ET@, dw, t, pf))
  +hd28 = FD.logic__subst(Nat, z => {Nat.is_lt(z, 28n) == True{} : Bool}, ER.LDEP(@ET@, FD.array__freeze(@ET@, FD.array__thaw(@ET@, t))), dw, ed, hd0)
  +hq = FD.nat__le_trans(Nat.mul(U32.to_nat(N), @RS@n), Nat.mul(FD.spec_common__pow2(dw), @RS@n), A.quad(VB.pw(dw)), VRL.mul_mono(U32.to_nat(N), FD.spec_common__pow2(dw), @RS@n, hN), mq(FD.spec_common__pow2(dw), @RS@n, {==}))
  +hok = @OKP@
  +ev = Equal.trans(S.Value, RT2.xv_@T@(@X@.TH(@X@.MW{dw, t, N})), S.Sequence{RT2.xi_@T@(U32.to_nat(N), FD.array__slots(@ET@, t), 0n)}, @X@.VAL(@X@.MW{dw, t, N}),
    Equal.cong(FD.array__Tree<@ET@>, S.Value, z => S.Sequence{RT2.xi_@T@(U32.to_nat(N), FD.array__slots(@ET@, z), 0n)}, FD.array__freeze(@ET@, FD.array__thaw(@ET@, t)), t, FD.array__freeze_thaw(@ET@, t)),
    Equal.cong(S.Value, S.Value, z => S.Sequence{z}, RT2.xi_@T@(U32.to_nat(N), FD.array__slots(@ET@, t), 0n), @X@.ITS(U32.to_nat(N), t, 0n), its_@T@(U32.to_nat(N), t, 0n, dw, pf, er, hN)))
  +ln = FD.logic__subst(Nat, z => {Nat.is_le(z, @BND@) == True{} : Bool}, Nat.mul(U32.to_nat(N), @RS@n), LY.LN(@X@.RBS(U32.to_nat(N), t, 0n)), Equal.sym(Nat, LY.LN(@X@.RBS(U32.to_nat(N), t, 0n)), Nat.mul(U32.to_nat(N), @RS@n), lrbs_@T@(U32.to_nat(N), t, 0n)), @LNP@)
  (@X@.MW{dw, t, N}, (eo, (ev, (hok, ln))))

def rb_@T@(-o: @LD@.@T@_Seq, +s: S.Schema, +rp: RT2.rep_@T@(o, s), @LIMS@+hp: PRL_@T@(o)) -> LRR_@T@(o):
@RBB@
"""


def _encl_rl(T):
    fn, X, ED, EN, EE, RS, fk, lim, LD = ENCL_RL[T]
    ET = f'{ED}.{EN}'
    fv = ', '.join(f'+x{i}' for i in range(len(fk)))
    xs = [f'x{i}' for i in range(len(fk))]
    # rp destructure names h0.. (a single field's rp is the fact itself)
    if len(fk) == 1:
        dst = ['      +h0 = rp']
    else:
        dst = []
        cur = 'rp'
        for i in range(len(fk) - 1):
            nxt = f'rq{i}'
            last = (i == len(fk) - 2)
            dst.append(f'      (+h{i}, +{f"h{i + 1}" if last else nxt}) = {cur}')
            cur = nxt
    valid = {'u16': lambda x: f'uint16_e.u16_valid({x})', 'u8': lambda x: f'uint8_e.u8_valid({x})'}
    vpf = {'u16': lambda x, h: f'GW.u16v({x}, {h})',
           'u8': lambda x, h: (f'FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat({x}), U32.to_nat(255)), U32.is_le({x}, 255), '
                               f'Equal.sym(Bool, U32.is_le({x}, 255), Nat.is_le(U32.to_nat({x}), U32.to_nat(255)), VU.le_u32({x}, 255)), LB.small({x}, {h}))')}
    props = [valid[k](x) for k, x in zip(fk, xs)]
    prfs = [vpf[k](x, f'h{i}') for i, (k, x) in enumerate(zip(fk, xs))]
    body = prfs[-1]
    for i in range(len(fk) - 2, -1, -1):
        rest = props[-1]
        for p in reversed(props[i + 1:-1]):
            rest = f'Bool.and({p}, {rest})'
        body = f'FD.logic__and_intro({props[i]}, {rest}, {prfs[i]}, {body})'
    vrpb = '\n'.join(dst + [f'      {body}'])
    # view: RN.v item = UnsignedValue{UInt{x}}; RV item = VRB.UV16(x) / UV8(x)
    UI = lambda v: f'S.UnsignedValue{{P.UInt{{{v}, 0, 0, 0, 0, 0, 0, 0}}}}'  # noqa: E731
    rv = {'u16': lambda x: f'VRB.UV16({x})', 'u8': lambda x: f'VRB.UV8({x})'}
    inner = {'u16': lambda x: f'PBM.v16of(U32.and({x}, 255), U32.and(U32.shrn({x}, 8n), 255))', 'u8': lambda x: f'U32.and({x}, 255)'}
    eqp = {'u16': lambda x, h: f'GW.eq16({x}, {h})', 'u8': lambda x, h: f'VBB.ea({x}, {h})'}

    def seq(items):
        out = 'S.EmptyItems{}'
        for it in reversed(items):
            out = f'S.Items{{{it}, {out}}}'
        return f'S.Sequence{{{out}}}'
    steps = []
    for i, (k, x) in enumerate(zip(fk, xs)):
        it = [UI(xs[q]) if q < i else (UI('_') if q == i else rv[fk[q]](xs[q])) for q in range(len(fk))]
        steps.append(f'      %Equal.sym(U32, {inner[k](x)}, {x}, {eqp[k](x, f"h{i}")}) : {{RN.v_{EN}({ET}{{{", ".join(xs)}}}) == {seq(it)} : S.Value}}')
    rvvb = '\n'.join(dst + steps + ['      {==}'])
    BND = 'P1()' if lim is None else f'{lim}n'
    if lim is None:
        prlb = f'DK.P2({{Nat.is_lt(ER.LDEP({ET}, FD.array__freeze({ET}, arr)), 28n) == True{{}} : Bool}}, {{Nat.is_le(Nat.mul(U32.to_nat(N), {RS}n), P1()) == True{{}} : Bool}})'
        pdoc = ', its bytes within P1'
        hpd = '  (+hd0, +hl) = hp'
        limp = ''
        lnp = 'hl'
        lims = ''
    else:
        prlb = f'{{Nat.is_lt(ER.LDEP({ET}, FD.array__freeze({ET}, arr)), 28n) == True{{}} : Bool}}'
        pdoc = ' (its bytes are within the limit)'
        hpd = '  +hd0 = hp'
        limp = f'+hlim: {{Nat.is_le(U32.to_nat(N), {lim}n) == True{{}} : Bool}}, '
        lnp = f'VRL.mul_mono(U32.to_nat(N), {lim}n, {RS}n, hlim)'
        lims = f'+es: {{SH.ListOf_limit(s) == {lim}n : Nat}}, '
    # OK conjunctions
    okl = [(f'Nat.is_lt(dw, 28n)', 'hd28'), (f'FD.array__perfect({ET}, dw, t)', 'pf'), ('Nat.is_le(U32.to_nat(N), VB.pw(dw))', 'hN'),
           (f'Nat.is_le(Nat.mul(U32.to_nat(N), {RS}n), A.quad(VB.pw(dw)))', 'hq')]
    if lim is not None:
        okl.append((f'U32.is_le(N, {lim})', f'''FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(N), U32.to_nat({lim})), U32.is_le(N, {lim}),
    Equal.sym(Bool, U32.is_le(N, {lim}), Nat.is_le(U32.to_nat(N), U32.to_nat({lim})), VU.le_u32(N, {lim})), hlim)'''))
    okl.append((f'{X}.VOK(U32.to_nat(N), t, 0n)', 'vok_' + T + '(U32.to_nat(N), t, 0n, dw, pf, er, hN)'))
    okp = okl[-1][1]
    for i in range(len(okl) - 2, -1, -1):
        rest = okl[-1][0]
        for p, _ in reversed(okl[i + 1:-1]):
            rest = f'Bool.and({p}, {rest})'
        okp = f'FD.logic__and_intro({okl[i][0]}, {rest}, {okl[i][1]},\n    {okp})'
    if lim is None:
        rbb = f'''  (+t, +r1) = rp
  (+dw, +r2) = r1
  (+N, +r3) = r2
  (+eo, +r4) = r3
  (+pf, +r5) = r4
  (+hd32, +r6) = r5
  (+hN, +er) = r6
  rb2_{T}(o, t, dw, N, eo, pf, hN, er, FD.logic__subst({LD}.{T}_Seq, z => PRL_{T}(z), o, {LD}.{T}_Seq{{FD.array__thaw({ET}, t), N}}, eo, hp))'''
    else:
        rbb = f'''  (+ex, +hl0) = rp
  rb1_{T}(o, s, ex, hl0, es, hp)'''
        # an extra layer: the existential then the limit
    txt = (ENCL_RL_PER.replace('@VRPB@', vrpb).replace('@RVVB@', rvvb).replace('@PRLB@', prlb).replace('@PDOC@', pdoc).replace('@HPD@', hpd)
           .replace('@LIMP@', limp).replace('@LNP@', lnp).replace('@LIMS@', lims).replace('@OKP@', okp).replace('@RBB@', rbb).replace('@BND@', BND)
           .replace('@FV@', fv).replace('@ET@', ET).replace('@ED@', ED).replace('@EN@', EN).replace('@EE@', EE).replace('@RS@', str(RS))
           .replace('@LD@', LD).replace('@X@', X).replace('@T@', T))
    if lim is not None:
        txt = txt.replace(f'def rb_{T}(', f'''def rb1_{T}(-o: {LD}.{T}_Seq, +s: S.Schema, +ex: DK.Ex(FD.array__Tree<{ET}>, t => DK.Ex(Nat, dw => DK.Ex(U32, N =>
    DK.P2({{o == {LD}.{T}_Seq{{FD.array__thaw({ET}, t), N}} : {LD}.{T}_Seq}},
    DK.P2({{FD.array__perfect({ET}, dw, t) == True{{}} : Bool}},
    DK.P2({{Nat.is_lt(dw, 32n) == True{{}} : Bool}},
    DK.P2({{Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{{}} : Bool}},
          RT2.ereps_{T}(U32.to_nat(N), FD.array__slots({ET}, t), 0n)))))))),
    +hl0: {{Nat.is_le(U32.to_nat(RT2.xlen_o_{T}(o)), SH.ListOf_limit(s)) == True{{}} : Bool}}, {lims}+hp: PRL_{T}(o)) -> LRR_{T}(o):
  (+t, +r1) = ex
  (+dw, +r2) = r1
  (+N, +r3) = r2
  (+eo, +r4) = r3
  (+pf, +r5) = r4
  (+hd32, +r6) = r5
  (+hN, +er) = r6
  +hlim = FD.logic__subst(Nat, z => {{Nat.is_le(U32.to_nat(RT2.xlen_o_{T}(o)), z) == True{{}} : Bool}}, SH.ListOf_limit(s), {lim}n, es, hl0)
  +hlim2 = FD.logic__subst({LD}.{T}_Seq, z => {{Nat.is_le(U32.to_nat(RT2.xlen_o_{T}(z)), {lim}n) == True{{}} : Bool}}, o, {LD}.{T}_Seq{{FD.array__thaw({ET}, t), N}}, eo, hlim)
  rb2_{T}(o, t, dw, N, eo, pf, hN, er, hlim2, FD.logic__subst({LD}.{T}_Seq, z => PRL_{T}(z), o, {LD}.{T}_Seq{{FD.array__thaw({ET}, t), N}}, eo, hp))

def rb_{T}(''', 1)
    imps = [f'import ../proofs/obj/{fn}.bend as {X}', f'import ../types/{ED[:-2]}_def_generated.bend as {ED}', f'import ../types/{EE[:-2]}_encode_ssz_generated.bend as {EE}',
            f'import ../types/{LD[:-2]}_def_generated.bend as {LD}']
    return txt, imps

# lists of variable-size elements: tag -> (EX list file, alias, element tag, element EX alias, element object type, list def alias)
ENCL_VL = {
    'pl_Gc465214E502': ('big_encx_pl_Gc465214E502', 'XA', 'Gc465214E502', 'XVT', 'VarTestStruct_d.Gc465214E502', 'proglist_VarTestStruct_d'),
    'pl_pl_Gc465214E502': ('big_encx_pl_pl_Gc465214E502', 'XB', 'pl_Gc465214E502', 'XA', 'proglist_VarTestStruct_d.pl_Gc465214E502_Seq', 'proglist_proglist_VarTestStruct_d'),
    'pl_Gp66304057C3': ('big_encx_pl_Gp66304057C3', 'XC', 'Gp66304057C3', 'CIG', 'ProgressiveVarTestStruct_d.Gp66304057C3', 'proglist_ProgressiveVarTestStruct_d'),
}

ENCL_VL_G = r"""# ---- ProgressiveVarTestStruct elements: the record CIG.MW{a0, Xl123.MW{LDEP(t), t, n}, EXP.MB{LDEP(tb), tb, k, k, 31, 30}} of M{a0, WMr{t, n}, BMr{tb, k}} ----
def fw_g(w: RT2.WMr) -> Xl123.MW:
  match w:
    case RT2.WMr{+t, +n}: Xl123.MW{ER.LDEP(U32, t), t, n}
def fb_g(b: RT2.BMr) -> EXP.MB:
  match b:
    case RT2.BMr{+t, +k}: EXP.MB{ER.LDEP(U32, t), t, k, U32.to_nat(k), 31n, 30n}
def fE_Gp66304057C3(m: RT2.M_Gp66304057C3) -> CIG.MW:
  match m:
    case RT2.M_Gp66304057C3{+a0, +a1, +a2}: CIG.MW{a0, fw_g(a1), fb_g(a2)}
def thg2(+a0: U32, +t: FD.array__Tree<U32>, +n: U32, +b: RT2.BMr) -> {CIG.TH(CIG.MW{a0, fw_g(RT2.WMr{t, n}), fb_g(b)}) == RT2.th_Gp66304057C3(RT2.M_Gp66304057C3{a0, RT2.WMr{t, n}, b}) : ProgressiveVarTestStruct_d.Gp66304057C3}:
  match b:
    case RT2.BMr{+tb, +k}: {==}
def thg1(+a0: U32, +w: RT2.WMr, +b: RT2.BMr) -> {CIG.TH(CIG.MW{a0, fw_g(w), fb_g(b)}) == RT2.th_Gp66304057C3(RT2.M_Gp66304057C3{a0, w, b}) : ProgressiveVarTestStruct_d.Gp66304057C3}:
  match w:
    case RT2.WMr{+t, +n}: thg2(a0, t, n, b)
def thE_Gp66304057C3(+m: RT2.M_Gp66304057C3) -> {CIG.TH(fE_Gp66304057C3(m)) == RT2.th_Gp66304057C3(m) : ProgressiveVarTestStruct_d.Gp66304057C3}:
  match m:
    case RT2.M_Gp66304057C3{+a0, +a1, +a2}: thg1(a0, a1, a2)
def EPB_g(b: RT2.BMr) -> Data:
  match b:
    case RT2.BMr{+t, +k}: EP.SDPB(O.Bits{FD.array__thaw(U32, t), k}, 28n)
def EP_Gp66304057C3(m: RT2.M_Gp66304057C3) -> Data:
  match m:
    case RT2.M_Gp66304057C3{+a0, +a1, +a2}: DK.P2(EPW_vt(a1), EPB_g(a2))
def SFE_Gp66304057C3(+s: S.Schema) -> Data: {SH.ListOf_limit(SH.Chain_head(SH.Chain_tail(SH.ProgressiveContainer_fields(s)))) == 123n : Nat}
def EF_Gp66304057C3(+m: RT2.M_Gp66304057C3) -> Data:
  DK.P2({CIG.OK(fE_Gp66304057C3(m)) == True{} : Bool}, {CIG.VAL(fE_Gp66304057C3(m)) == RT2.v_Gp66304057C3(RT2.th_Gp66304057C3(m)) : S.Value})
def g0(o: ProgressiveVarTestStruct_d.Gp66304057C3) -> U32:
  match o:
    case ProgressiveVarTestStruct_d.Gp66304057C3{+x0, x1, x2}: x0
def bta(o: O.Bits) -> FD.array__Tree<U32>:
  match o:
    case O.Bits{a, +k}: FD.array__freeze(U32, a)
def btk(o: O.Bits) -> U32:
  match o:
    case O.Bits{a, +k}: k

# the bit list's premise, at the element's own tree and length
def pbx(+tb: FD.array__Tree<U32>, +k: U32, +hs: EP.SDPB(O.Bits{FD.array__thaw(U32, tb), k}, 28n), +wf: BO.wfb(O.Bits{FD.array__thaw(U32, tb), k})) -> EP.PBF3(ER.LDEP(U32, tb), tb, k):
  (+T2, +s1) = hs
  (+dw2, +s2) = s1
  (+K2, +s3) = s2
  (+eo, +s4) = s3
  (+pf, +s5) = s4
  (+hdw, +s6) = s5
  (+hK8, +s7) = s6
  (+hKY, +s8) = s7
  (+hroom, +hbz) = s8
  +eT = Equal.trans(FD.array__Tree<U32>, tb, FD.array__freeze(U32, FD.array__thaw(U32, tb)), T2, Equal.sym(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, tb)), tb, FD.array__freeze_thaw(U32, tb)),
    Equal.trans(FD.array__Tree<U32>, FD.array__freeze(U32, FD.array__thaw(U32, tb)), FD.array__freeze(U32, FD.array__thaw(U32, T2)), T2,
      Equal.cong(O.Bits, FD.array__Tree<U32>, z => bta(z), O.Bits{FD.array__thaw(U32, tb), k}, O.Bits{FD.array__thaw(U32, T2), K2}, eo), FD.array__freeze_thaw(U32, T2)))
  +eK = Equal.cong(O.Bits, U32, z => btk(z), O.Bits{FD.array__thaw(U32, tb), k}, O.Bits{FD.array__thaw(U32, T2), K2}, eo)
  +ed = Equal.trans(Nat, ER.LDEP(U32, tb), ER.LDEP(U32, T2), dw2, Equal.cong(FD.array__Tree<U32>, Nat, z => ER.LDEP(U32, z), tb, T2, eT), ER.pdep(U32, dw2, T2, pf))
  +wf2 = FD.logic__subst(O.Bits, z => BO.wfb(z), O.Bits{FD.array__thaw(U32, tb), k}, O.Bits{FD.array__thaw(U32, T2), K2}, eo, wf)
  %Equal.sym(Nat, ER.LDEP(U32, tb), dw2, ed) : EP.PBF3(_, tb, k)
  %Equal.sym(FD.array__Tree<U32>, tb, T2, eT) : EP.PBF3(dw2, _, k)
  %Equal.sym(U32, k, K2, eK) : EP.PBF3(dw2, T2, _)
  EP.pbf(T2, dw2, K2, pf, FD.nat__lt_trans(dw2, 28n, 31n, hdw, {==}), hK8, hKY, hroom, hbz, wf2)

def efg4(+a0: U32, +t: FD.array__Tree<U32>, +n: U32, +tb: FD.array__Tree<U32>, +k: U32, +f: EQ.CF_Gp66304057C3(a0, fw_g(RT2.WMr{t, n}), fb_g(RT2.BMr{tb, k})))
    -> EF_Gp66304057C3(RT2.M_Gp66304057C3{a0, RT2.WMr{t, n}, RT2.BMr{tb, k}}):
  (+fv, +f1) = f
  (+fo, +fl) = f1
  (fo, Equal.sym(S.Value, RT2.v_Gp66304057C3(RT2.th_Gp66304057C3(RT2.M_Gp66304057C3{a0, RT2.WMr{t, n}, RT2.BMr{tb, k}})), CIG.VAL(fE_Gp66304057C3(RT2.M_Gp66304057C3{a0, RT2.WMr{t, n}, RT2.BMr{tb, k}})), fv))
def efg5(+a0: U32, +t: FD.array__Tree<U32>, +n: U32, +tb: FD.array__Tree<U32>, +k: U32, +h0: {U32.is_lt(a0, 256) == True{} : Bool}, +c: Nat,
    +hx: {U32.to_nat(n) == Nat.double(c) : Nat}, +hl: {Nat.is_le(c, 123n) == True{} : Bool}, +hsw: BL.sdk(O.Words{FD.array__thaw(U32, t), n}, 28n), +pb: EP.PBF3(ER.LDEP(U32, tb), tb, k))
    -> EF_Gp66304057C3(RT2.M_Gp66304057C3{a0, RT2.WMr{t, n}, RT2.BMr{tb, k}}):
  (+v2, +p1) = pb
  (+o2, +l2) = p1
  +o1 = ER.ok_l123(t, n, ER.sfk(t, n, 28n, hsw), c, hx, hl)
  efg4(a0, t, n, tb, k, EQ.c1f_Gp66304057C3(a0, fw_g(RT2.WMr{t, n}), fb_g(RT2.BMr{tb, k}), h0, ER.lv_l123(t, n, c, hx, hl), v2, o1, o2, ER.ln_l123(t, n, o1, c, hx, hl), l2))
def efg3(+a0: U32, +t: FD.array__Tree<U32>, +n: U32, +tb: FD.array__Tree<U32>, +k: U32, +s: S.Schema,
    +rp: RT2.rep_Gp66304057C3(RT2.th_Gp66304057C3(RT2.M_Gp66304057C3{a0, RT2.WMr{t, n}, RT2.BMr{tb, k}}), s),
    +ep: DK.P2(BL.sdk(O.Words{FD.array__thaw(U32, t), n}, 28n), EP.SDPB(O.Bits{FD.array__thaw(U32, tb), k}, 28n)), +es: SFE_Gp66304057C3(s))
    -> EF_Gp66304057C3(RT2.M_Gp66304057C3{a0, RT2.WMr{t, n}, RT2.BMr{tb, k}}):
  (+x0, +r0) = rp
  (+ev, +q0) = r0
  (+h0, +q1) = q0
  (+rl, +wf) = q1
  (+wfl, +z1) = rl
  (+hx, +hl) = z1
  (+hsw, +hsb) = ep
  +e0 = Equal.cong(ProgressiveVarTestStruct_d.Gp66304057C3, U32, z => g0(z), ProgressiveVarTestStruct_d.Gp66304057C3{a0, O.Words{FD.array__thaw(U32, t), n}, O.Bits{FD.array__thaw(U32, tb), k}},
    ProgressiveVarTestStruct_d.Gp66304057C3{x0, O.Words{FD.array__thaw(U32, t), n}, O.Bits{FD.array__thaw(U32, tb), k}}, ev)
  +h0a = FD.logic__subst(U32, z => {U32.is_lt(z, 256) == True{} : Bool}, x0, a0, Equal.sym(U32, a0, x0, e0), h0)
  +hl2 = FD.logic__subst(Nat, z => {Nat.is_le(PBF.cnt2(O.Words{FD.array__thaw(U32, t), n}), z) == True{} : Bool}, SH.ListOf_limit(SH.Chain_head(SH.Chain_tail(SH.ProgressiveContainer_fields(s)))), 123n, es, hl)
  efg5(a0, t, n, tb, k, h0a, PBF.cnt2(O.Words{FD.array__thaw(U32, t), n}), hx, hl2, hsw, pbx(tb, k, hsb, wf))
def efg2(+a0: U32, +t: FD.array__Tree<U32>, +n: U32, +b: RT2.BMr, +s: S.Schema, +rp: RT2.rep_Gp66304057C3(RT2.th_Gp66304057C3(RT2.M_Gp66304057C3{a0, RT2.WMr{t, n}, b}), s),
    +ep: DK.P2(BL.sdk(O.Words{FD.array__thaw(U32, t), n}, 28n), EPB_g(b)), +es: SFE_Gp66304057C3(s)) -> EF_Gp66304057C3(RT2.M_Gp66304057C3{a0, RT2.WMr{t, n}, b}):
  match b:
    case RT2.BMr{+tb, +k}: efg3(a0, t, n, tb, k, s, rp, ep, es)
def efg1(+a0: U32, +w: RT2.WMr, +b: RT2.BMr, +s: S.Schema, +rp: RT2.rep_Gp66304057C3(RT2.th_Gp66304057C3(RT2.M_Gp66304057C3{a0, w, b}), s),
    +ep: DK.P2(EPW_vt(w), EPB_g(b)), +es: SFE_Gp66304057C3(s)) -> EF_Gp66304057C3(RT2.M_Gp66304057C3{a0, w, b}):
  match w:
    case RT2.WMr{+t, +n}: efg2(a0, t, n, b, s, rp, ep, es)
def ef_Gp66304057C3(+m: RT2.M_Gp66304057C3, +s: S.Schema, +rp: RT2.rep_Gp66304057C3(RT2.th_Gp66304057C3(m), s), +ep: EP_Gp66304057C3(m), +es: SFE_Gp66304057C3(s)) -> EF_Gp66304057C3(m):
  match m:
    case RT2.M_Gp66304057C3{+a0, +a1, +a2}: efg1(a0, a1, a2, s, rp, ep, es)
"""

ENCL_VL_SHARED = r"""# ---- lists of variable-size elements: shared ----
# x within P + 1 bytes fits 8 P (P symbolic: a closed P1 would be evaluated)
def llq(+x: Nat, +P: Nat, +hx: {Nat.is_le(x, Nat.add(P, 1n)) == True{} : Bool}, +hc: {Nat.is_le(Nat.add(0n, 1n), P) == True{} : Bool}) -> {Nat.is_le(x, A.quad(Nat.double(P))) == True{} : Bool}:
  EP.bnd(0n, x, P, hx, hc)

# ---- VarTestStruct elements: the record XVT.MW{a0, Xl1024.MW{LDEP(t), t, n}, a2} of the mirror M{a0, WMr{t, n}, a2} ----
def fw_vt(w: RT2.WMr) -> Xl1024.MW:
  match w:
    case RT2.WMr{+t, +n}: Xl1024.MW{ER.LDEP(U32, t), t, n}
def fE_Gc465214E502(m: RT2.M_Gc465214E502) -> XVT.MW:
  match m:
    case RT2.M_Gc465214E502{+a0, +a1, +a2}: XVT.MW{a0, fw_vt(a1), a2}
def thw_vt(+a0: U32, +w: RT2.WMr, +a2: U32) -> {XVT.TH(XVT.MW{a0, fw_vt(w), a2}) == RT2.th_Gc465214E502(RT2.M_Gc465214E502{a0, w, a2}) : VarTestStruct_d.Gc465214E502}:
  match w:
    case RT2.WMr{+t, +n}: {==}
def thE_Gc465214E502(+m: RT2.M_Gc465214E502) -> {XVT.TH(fE_Gc465214E502(m)) == RT2.th_Gc465214E502(m) : VarTestStruct_d.Gc465214E502}:
  match m:
    case RT2.M_Gc465214E502{+a0, +a1, +a2}: thw_vt(a0, a1, a2)
def EPW_vt(w: RT2.WMr) -> Data:
  match w:
    case RT2.WMr{+t, +n}: BL.sdk(O.Words{FD.array__thaw(U32, t), n}, 28n)
def EP_Gc465214E502(m: RT2.M_Gc465214E502) -> Data:
  match m:
    case RT2.M_Gc465214E502{+a0, +a1, +a2}: EPW_vt(a1)
def SFE_Gc465214E502(+s: S.Schema) -> Data: {SH.ListOf_limit(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))) == 1024n : Nat}
def EF_Gc465214E502(+m: RT2.M_Gc465214E502) -> Data:
  DK.P2({XVT.OK(fE_Gc465214E502(m)) == True{} : Bool}, {XVT.VAL(fE_Gc465214E502(m)) == RT2.v_Gc465214E502(RT2.th_Gc465214E502(m)) : S.Value})
def vt0(o: VarTestStruct_d.Gc465214E502) -> U32:
  match o:
    case VarTestStruct_d.Gc465214E502{+x0, x1, +x2}: x0
def vt2(o: VarTestStruct_d.Gc465214E502) -> U32:
  match o:
    case VarTestStruct_d.Gc465214E502{+x0, x1, +x2}: x2
def efv2(+a0: U32, +a2: U32, +t: FD.array__Tree<U32>, +n: U32, +f: ER.VTF(a0, a2, t, n)) -> EF_Gc465214E502(RT2.M_Gc465214E502{a0, RT2.WMr{t, n}, a2}):
  (+fv, +f1) = f
  (+fo, +fl) = f1
  (fo, Equal.sym(S.Value, RT2.v_Gc465214E502(RT2.th_Gc465214E502(RT2.M_Gc465214E502{a0, RT2.WMr{t, n}, a2})), XVT.VAL(fE_Gc465214E502(RT2.M_Gc465214E502{a0, RT2.WMr{t, n}, a2})), fv))
def efw_vt(+a0: U32, +t: FD.array__Tree<U32>, +n: U32, +a2: U32, +s: S.Schema,
    +rp: RT2.rep_Gc465214E502(RT2.th_Gc465214E502(RT2.M_Gc465214E502{a0, RT2.WMr{t, n}, a2}), s), +ep: BL.sdk(O.Words{FD.array__thaw(U32, t), n}, 28n), +es: SFE_Gc465214E502(s))
    -> EF_Gc465214E502(RT2.M_Gc465214E502{a0, RT2.WMr{t, n}, a2}):
  (+x0, +r0) = rp
  (+x2, +r1) = r0
  (+ev, +q1) = r1
  (+h0, +q2) = q1
  (+rl, +h2) = q2
  (+wf, +z1) = rl
  (+hx, +hl) = z1
  +e0 = Equal.cong(VarTestStruct_d.Gc465214E502, U32, z => vt0(z), VarTestStruct_d.Gc465214E502{a0, O.Words{FD.array__thaw(U32, t), n}, a2}, VarTestStruct_d.Gc465214E502{x0, O.Words{FD.array__thaw(U32, t), n}, x2}, ev)
  +e2 = Equal.cong(VarTestStruct_d.Gc465214E502, U32, z => vt2(z), VarTestStruct_d.Gc465214E502{a0, O.Words{FD.array__thaw(U32, t), n}, a2}, VarTestStruct_d.Gc465214E502{x0, O.Words{FD.array__thaw(U32, t), n}, x2}, ev)
  +h0a = FD.logic__subst(U32, z => {U32.is_lt(z, 65536) == True{} : Bool}, x0, a0, Equal.sym(U32, a0, x0, e0), h0)
  +h2a = FD.logic__subst(U32, z => {U32.is_lt(z, 256) == True{} : Bool}, x2, a2, Equal.sym(U32, a2, x2, e2), h2)
  +hl2 = FD.logic__subst(Nat, z => {Nat.is_le(PBF.cnt2(O.Words{FD.array__thaw(U32, t), n}), z) == True{} : Bool}, SH.ListOf_limit(SH.Chain_head(SH.Chain_tail(SH.Container_fields(s)))), 1024n, es, hl)
  efv2(a0, a2, t, n, ER.vtf(a0, a2, t, n, h0a, h2a, PBF.cnt2(O.Words{FD.array__thaw(U32, t), n}), hx, hl2, ep))
def efm_vt(+a0: U32, +w: RT2.WMr, +a2: U32, +s: S.Schema, +rp: RT2.rep_Gc465214E502(RT2.th_Gc465214E502(RT2.M_Gc465214E502{a0, w, a2}), s), +ep: EPW_vt(w), +es: SFE_Gc465214E502(s))
    -> EF_Gc465214E502(RT2.M_Gc465214E502{a0, w, a2}):
  match w:
    case RT2.WMr{+t, +n}: efw_vt(a0, t, n, a2, s, rp, ep, es)
def ef_Gc465214E502(+m: RT2.M_Gc465214E502, +s: S.Schema, +rp: RT2.rep_Gc465214E502(RT2.th_Gc465214E502(m), s), +ep: EP_Gc465214E502(m), +es: SFE_Gc465214E502(s)) -> EF_Gc465214E502(m):
  match m:
    case RT2.M_Gc465214E502{+a0, +a1, +a2}: efm_vt(a0, a1, a2, s, rp, ep, es)
"""

ENCL_VL_PL = r"""# ---- progressive lists of VarTestStruct as elements: the record XA.MW{TM(t), n} of the mirror M_pl{t, n} ----
def fE_pl_Gc465214E502(m: RT2.M_pl_Gc465214E502) -> XA.MW:
  match m:
    case RT2.M_pl_Gc465214E502{+t, +n}: XA.MW{TM_pl_Gc465214E502(t), n}
def thE_pl_Gc465214E502(+m: RT2.M_pl_Gc465214E502) -> {XA.TH(fE_pl_Gc465214E502(m)) == RT2.th_pl_Gc465214E502(m) : proglist_VarTestStruct_d.pl_Gc465214E502_Seq}:
  match m:
    case RT2.M_pl_Gc465214E502{+t, +n}:
      Equal.cong(Array<O.Boxed<VarTestStruct_d.Gc465214E502>>, proglist_VarTestStruct_d.pl_Gc465214E502_Seq, z => proglist_VarTestStruct_d.pl_Gc465214E502_Seq{z, n}, XA.AR(TM_pl_Gc465214E502(t)), RT2.am_pl_Gc465214E502(t), arTM_pl_Gc465214E502(t))
def EP_pl_Gc465214E502(m: RT2.M_pl_Gc465214E502) -> Data:
  match m:
    case RT2.M_pl_Gc465214E502{+t, +n}: PM_pl_Gc465214E502(t, n)
def SFE_pl_Gc465214E502(+s: S.Schema) -> Data: SFE_Gc465214E502(SH.ProgressiveList_element(s))
def EF_pl_Gc465214E502(+m: RT2.M_pl_Gc465214E502) -> Data:
  DK.P2({XA.OK(fE_pl_Gc465214E502(m)) == True{} : Bool}, {XA.VAL(fE_pl_Gc465214E502(m)) == RT2.v_pl_Gc465214E502(RT2.th_pl_Gc465214E502(m)) : S.Value})
def sqa_A(o: proglist_VarTestStruct_d.pl_Gc465214E502_Seq) -> Array<O.Boxed<VarTestStruct_d.Gc465214E502>>:
  match o:
    case proglist_VarTestStruct_d.pl_Gc465214E502_Seq{arr, +n}: arr
def sqn_A(o: proglist_VarTestStruct_d.pl_Gc465214E502_Seq) -> U32:
  match o:
    case proglist_VarTestStruct_d.pl_Gc465214E502_Seq{arr, +n}: n
def efq_A(+t: FD.array__Tree<RT2.MB<RT2.M_Gc465214E502>>, +n: U32, +mk: MK_pl_Gc465214E502(t, n)) -> EF_pl_Gc465214E502(RT2.M_pl_Gc465214E502{t, n}):
  (+eth, +m1) = mk
  (+ev, +m2) = m1
  (+ok, +ln) = m2
  (ok, Equal.trans(S.Value, XA.VAL(XA.MW{TM_pl_Gc465214E502(t), n}), RT2.xv_pl_Gc465214E502(XA.TH(XA.MW{TM_pl_Gc465214E502(t), n})), RT2.xv_pl_Gc465214E502(proglist_VarTestStruct_d.pl_Gc465214E502_Seq{RT2.am_pl_Gc465214E502(t), n}),
    Equal.sym(S.Value, RT2.xv_pl_Gc465214E502(XA.TH(XA.MW{TM_pl_Gc465214E502(t), n})), XA.VAL(XA.MW{TM_pl_Gc465214E502(t), n}), ev),
    Equal.cong(proglist_VarTestStruct_d.pl_Gc465214E502_Seq, S.Value, z => RT2.xv_pl_Gc465214E502(z), XA.TH(XA.MW{TM_pl_Gc465214E502(t), n}), proglist_VarTestStruct_d.pl_Gc465214E502_Seq{RT2.am_pl_Gc465214E502(t), n}, eth)))
def efp_A(+t: FD.array__Tree<RT2.MB<RT2.M_Gc465214E502>>, +n: U32, +s: S.Schema, +rp: RT2.rep_pl_Gc465214E502(RT2.th_pl_Gc465214E502(RT2.M_pl_Gc465214E502{t, n}), s),
    +ep: PM_pl_Gc465214E502(t, n), +es: SFE_pl_Gc465214E502(s)) -> EF_pl_Gc465214E502(RT2.M_pl_Gc465214E502{t, n}):
  (+t2, +r1) = rp
  (+dw, +r2) = r1
  (+N2, +r3) = r2
  (+eo, +r4) = r3
  (+pf, +r5) = r4
  (+hd, +r6) = r5
  (+hN, +er) = r6
  +ea = Equal.cong(proglist_VarTestStruct_d.pl_Gc465214E502_Seq, Array<O.Boxed<VarTestStruct_d.Gc465214E502>>, z => sqa_A(z), proglist_VarTestStruct_d.pl_Gc465214E502_Seq{RT2.am_pl_Gc465214E502(t), n}, proglist_VarTestStruct_d.pl_Gc465214E502_Seq{RT2.am_pl_Gc465214E502(t2), N2}, eo)
  +et = Equal.trans(FD.array__Tree<RT2.MB<RT2.M_Gc465214E502>>, t, RT2.tfz_pl_Gc465214E502(RT2.am_pl_Gc465214E502(t)), t2,
    Equal.sym(FD.array__Tree<RT2.MB<RT2.M_Gc465214E502>>, RT2.tfz_pl_Gc465214E502(RT2.am_pl_Gc465214E502(t)), t, RT2.tfzam_pl_Gc465214E502(t)),
    Equal.trans(FD.array__Tree<RT2.MB<RT2.M_Gc465214E502>>, RT2.tfz_pl_Gc465214E502(RT2.am_pl_Gc465214E502(t)), RT2.tfz_pl_Gc465214E502(RT2.am_pl_Gc465214E502(t2)), t2,
      Equal.cong(Array<O.Boxed<VarTestStruct_d.Gc465214E502>>, FD.array__Tree<RT2.MB<RT2.M_Gc465214E502>>, z => RT2.tfz_pl_Gc465214E502(z), RT2.am_pl_Gc465214E502(t), RT2.am_pl_Gc465214E502(t2), ea),
      RT2.tfzam_pl_Gc465214E502(t2)))
  +en = Equal.cong(proglist_VarTestStruct_d.pl_Gc465214E502_Seq, U32, z => sqn_A(z), proglist_VarTestStruct_d.pl_Gc465214E502_Seq{RT2.am_pl_Gc465214E502(t), n}, proglist_VarTestStruct_d.pl_Gc465214E502_Seq{RT2.am_pl_Gc465214E502(t2), N2}, eo)
  +pf1 = FD.logic__subst(FD.array__Tree<RT2.MB<RT2.M_Gc465214E502>>, z => {FD.array__perfect(RT2.MB<RT2.M_Gc465214E502>, dw, z) == True{} : Bool}, t2, t, Equal.sym(FD.array__Tree<RT2.MB<RT2.M_Gc465214E502>>, t, t2, et), pf)
  +hN1 = FD.logic__subst(U32, z => {Nat.is_le(U32.to_nat(z), FD.spec_common__pow2(dw)) == True{} : Bool}, N2, n, Equal.sym(U32, n, N2, en), hN)
  +er1 = FD.logic__subst(FD.array__Tree<RT2.MB<RT2.M_Gc465214E502>>, z => RT2.ereps_pl_Gc465214E502(U32.to_nat(N2), FD.array__slots(RT2.MB<RT2.M_Gc465214E502>, z), 0n, SH.ProgressiveList_element(s)), t2, t, Equal.sym(FD.array__Tree<RT2.MB<RT2.M_Gc465214E502>>, t, t2, et), er)
  +er2 = FD.logic__subst(U32, z => RT2.ereps_pl_Gc465214E502(U32.to_nat(z), FD.array__slots(RT2.MB<RT2.M_Gc465214E502>, t), 0n, SH.ProgressiveList_element(s)), N2, n, Equal.sym(U32, n, N2, en), er1)
  efq_A(t, n, mk_pl_Gc465214E502(t, dw, n, SH.ProgressiveList_element(s), pf1, hN1, er2, ep, es))
def ef_pl_Gc465214E502(+m: RT2.M_pl_Gc465214E502, +s: S.Schema, +rp: RT2.rep_pl_Gc465214E502(RT2.th_pl_Gc465214E502(m), s), +ep: EP_pl_Gc465214E502(m), +es: SFE_pl_Gc465214E502(s)) -> EF_pl_Gc465214E502(m):
  match m:
    case RT2.M_pl_Gc465214E502{+t, +n}: efp_A(t, n, s, rp, ep, es)
"""

ENCL_VL_PER = r"""# ======== @L@ (@X@): a progressive list of @E@ ========
# the encode record's mirror tree of the root's mirror tree
def fbx_@L@(x: @MBR@) -> @MBX@:
  match x:
    case RT2.MNone{}: @X@.MNone{}
    case RT2.MSome{+m}: @X@.MSome{fE_@E@(m)}
def TM_@L@(t: FD.array__Tree<@MBR@>) -> FD.array__Tree<@MBX@>:
  match t:
    case FD.TLeaf{+x}: FD.TLeaf{fbx_@L@(x)}
    case FD.TNode{+l, +r}: FD.TNode{TM_@L@(l), TM_@L@(r)}
def MAPB_@L@(W: List<&2, @MBR@>) -> List<&2, @MBX@>:
  match W:
    case Nil{}: Nil{}
    case Con{+x, +r}: Con{fbx_@L@(x), MAPB_@L@(r)}
def mapp_@L@(+a: List<&2, @MBR@>, +b: List<&2, @MBR@>) -> {MAPB_@L@(FD.spec_common__append(@MBR@, a, b)) == FD.spec_common__append(@MBX@, MAPB_@L@(a), MAPB_@L@(b)) : List<&2, @MBX@>}:
  match a:
    case Nil{}: {==}
    case Con{+x, +r}: Equal.cong(List<&2, @MBX@>, List<&2, @MBX@>, z => Con{fbx_@L@(x), z}, MAPB_@L@(FD.spec_common__append(@MBR@, r, b)), FD.spec_common__append(@MBX@, MAPB_@L@(r), MAPB_@L@(b)), mapp_@L@(r, b))
def slTM_@L@(+t: FD.array__Tree<@MBR@>) -> {FD.array__slots(@MBX@, TM_@L@(t)) == MAPB_@L@(FD.array__slots(@MBR@, t)) : List<&2, @MBX@>}:
  match t:
    case FD.TLeaf{+x}: {==}
    case FD.TNode{+l, +r}:
      %Equal.sym(List<&2, @MBX@>, FD.array__slots(@MBX@, TM_@L@(l)), MAPB_@L@(FD.array__slots(@MBR@, l)), slTM_@L@(l)) :
        {FD.spec_common__append(@MBX@, _, FD.array__slots(@MBX@, TM_@L@(r))) == MAPB_@L@(FD.spec_common__append(@MBR@, FD.array__slots(@MBR@, l), FD.array__slots(@MBR@, r))) : List<&2, @MBX@>}
      %Equal.sym(List<&2, @MBX@>, FD.array__slots(@MBX@, TM_@L@(r)), MAPB_@L@(FD.array__slots(@MBR@, r)), slTM_@L@(r)) :
        {FD.spec_common__append(@MBX@, MAPB_@L@(FD.array__slots(@MBR@, l)), _) == MAPB_@L@(FD.spec_common__append(@MBR@, FD.array__slots(@MBR@, l), FD.array__slots(@MBR@, r))) : List<&2, @MBX@>}
      Equal.sym(List<&2, @MBX@>, MAPB_@L@(FD.spec_common__append(@MBR@, FD.array__slots(@MBR@, l), FD.array__slots(@MBR@, r))), FD.spec_common__append(@MBX@, MAPB_@L@(FD.array__slots(@MBR@, l)), MAPB_@L@(FD.array__slots(@MBR@, r))),
        mapp_@L@(FD.array__slots(@MBR@, l), FD.array__slots(@MBR@, r)))
def xatM_@L@(+W: List<&2, @MBR@>, +i: Nat) -> {@X@.xat_@L@(MAPB_@L@(W), i) == fbx_@L@(RT2.xat_@L@(W, i)) : @MBX@}:
  match W i:
    case Nil{} _: {==}
    case Con{+x, +r} 0n: {==}
    case Con{+x, +r} 1n+ +j: xatM_@L@(r, j)
def thx_@L@(+x: @MBR@) -> {@X@.th_@E@_bx(fbx_@L@(x)) == RT2.th_@E@_bx(x) : O.Boxed<@ETY@>}:
  match x:
    case RT2.MNone{}: {==}
    case RT2.MSome{+m}: Equal.cong(@ETY@, O.Boxed<@ETY@>, z => O.BSome{z, O.BNone{}}, @EMA@.TH(fE_@E@(m)), RT2.th_@E@(m), thE_@E@(m))
def arTM_@L@(+t: FD.array__Tree<@MBR@>) -> {@X@.AR(TM_@L@(t)) == RT2.am_@L@(t) : Array<O.Boxed<@ETY@>>}:
  match t:
    case FD.TLeaf{+x}: Equal.cong(O.Boxed<@ETY@>, Array<O.Boxed<@ETY@>>, z => ALeaf{z}, @X@.th_@E@_bx(fbx_@L@(x)), RT2.th_@E@_bx(x), thx_@L@(x))
    case FD.TNode{+l, +r}:
      %Equal.sym(Array<O.Boxed<@ETY@>>, @X@.AR(TM_@L@(l)), RT2.am_@L@(l), arTM_@L@(l)) : {ANode{_, @X@.AR(TM_@L@(r))} == ANode{RT2.am_@L@(l), RT2.am_@L@(r)} : Array<O.Boxed<@ETY@>>}
      %Equal.sym(Array<O.Boxed<@ETY@>>, @X@.AR(TM_@L@(r)), RT2.am_@L@(r), arTM_@L@(r)) : {ANode{RT2.am_@L@(l), _} == ANode{RT2.am_@L@(l), RT2.am_@L@(r)} : Array<O.Boxed<@ETY@>>}
      {==}
def pfTM_@L@(+d: Nat, +t: FD.array__Tree<@MBR@>, +pf: {FD.array__perfect(@MBR@, d, t) == True{} : Bool}) -> {FD.array__perfect(@MBX@, d, TM_@L@(t)) == True{} : Bool}:
  match d t:
    case 0n FD.TLeaf{+x}: {==}
    case 0n FD.TNode{+l, +r}: Empty.absurd({FD.array__perfect(@MBX@, 0n, TM_@L@(FD.TNode{l, r})) == True{} : Bool}, FD.logic__false_true(pf))
    case 1n+ +p FD.TLeaf{+x}: Empty.absurd({FD.array__perfect(@MBX@, 1n+p, TM_@L@(FD.TLeaf{x})) == True{} : Bool}, FD.logic__false_true(pf))
    case 1n+ +p FD.TNode{+l, +r}:
      FD.logic__and_intro(FD.array__perfect(@MBX@, p, TM_@L@(l)), FD.array__perfect(@MBX@, p, TM_@L@(r)), pfTM_@L@(p, l, FD.array__pf_left(@MBR@, p, l, r, pf)), pfTM_@L@(p, r, FD.array__pf_right(@MBR@, p, l, r, pf)))
def tdTM_@L@(+d: Nat, +t: FD.array__Tree<@MBR@>, +pf: {FD.array__perfect(@MBR@, d, t) == True{} : Bool}) -> {@X@.TDM(TM_@L@(t)) == d : Nat}:
  match d t:
    case 0n FD.TLeaf{+x}: {==}
    case 0n FD.TNode{+l, +r}: Empty.absurd({@X@.TDM(TM_@L@(FD.TNode{l, r})) == 0n : Nat}, FD.logic__false_true(pf))
    case 1n+ +p FD.TLeaf{+x}: Empty.absurd({@X@.TDM(TM_@L@(FD.TLeaf{x})) == 1n+p : Nat}, FD.logic__false_true(pf))
    case 1n+ +p FD.TNode{+l, +r}: Equal.cong(Nat, Nat, z => 1n+z, @X@.TDM(TM_@L@(l)), p, tdTM_@L@(p, l, FD.array__pf_left(@MBR@, p, l, r, pf)))

# the premise: the mirror tree at depth below 31, the list's bytes within P1, each element's premise
def EPB_@L@(x: @MBR@) -> Data:
  match x:
    case RT2.MNone{}: {True{} == True{} : Bool}
    case RT2.MSome{+m}: EP_@E@(m)
def EPS_@L@(k: Nat, +W: List<&2, @MBR@>, +i: Nat) -> Data:
  match k:
    case 0n: {True{} == True{} : Bool}
    case 1n+q: DK.P2(EPB_@L@(RT2.xat_@L@(W, i)), EPS_@L@(q, W, 1n+i))
def PM_@L@(+t: FD.array__Tree<@MBR@>, +N: U32) -> Data:
  DK.P2({Nat.is_lt(ER.LDEP(@MBR@, t), 31n) == True{} : Bool}, DK.P2({Nat.is_le(@X@.LL(TM_@L@(t), N), P1()) == True{} : Bool}, EPS_@L@(U32.to_nat(N), FD.array__slots(@MBR@, t), 0n)))
def PRV_@L@(o: @SEQ@) -> Data:
  match o:
    case @SEQ@{arr, +N}: PM_@L@(RT2.tfz_@L@(arr), N)

# an element the root law represents, with its premise: valid, and its value the root's view
def EFX_@L@(+x: @MBR@) -> Data: DK.P2({@X@.EOK(fbx_@L@(x)) == True{} : Bool}, {@X@.EV(fbx_@L@(x)) == RT2.v_@E@_bx(RT2.th_@E@_bx(x)) : S.Value})
def isS_@L@(b: O.Boxed<@ETY@>) -> Bool:
  match b:
    case O.BSome{v, r}: True{}
    case O.BNone{}: False{}
def efx_@L@(+x: @MBR@, +sE: S.Schema, +rb: RT2.rep_@E@_bx(RT2.th_@E@_bx(x), sE), +ep: EPB_@L@(x), +es: SFE_@E@(sE)) -> EFX_@L@(x):
  match x:
    case RT2.MNone{}:
      (+eq, +rr) = rb
      Empty.absurd(EFX_@L@(RT2.MNone{}), FD.logic__false_true(Equal.cong(O.Boxed<@ETY@>, Bool, b => isS_@L@(b), O.BNone{}, O.BSome{RT2.pjb_@E@_bx(O.BNone{}), O.BNone{}}, eq)))
    case RT2.MSome{+m}:
      (+eq, +rr) = rb
      ef_@E@(m, sE, rr, ep, es)
def EXS_@L@(k: Nat, +W: List<&2, @MBR@>, +i: Nat) -> Data:
  DK.P2({@X@.EOKS(k, MAPB_@L@(W), i) == True{} : Bool}, {@X@.XI(k, MAPB_@L@(W), i) == RT2.xi_@L@(k, W, i) : S.Value})
def exs2_@L@(+q: Nat, +W: List<&2, @MBR@>, +i: Nat, +f: EFX_@L@(RT2.xat_@L@(W, i)), +ih: EXS_@L@(q, W, 1n+i)) -> EXS_@L@(1n+q, W, i):
  (+fo, +fv) = f
  (+io, +iv) = ih
  +ex = xatM_@L@(W, i)
  +xa = RT2.xat_@L@(W, i)
  +ho = FD.logic__subst(@MBX@, z => {@X@.EOK(z) == True{} : Bool}, fbx_@L@(xa), @X@.xat_@L@(MAPB_@L@(W), i), Equal.sym(@MBX@, @X@.xat_@L@(MAPB_@L@(W), i), fbx_@L@(xa), ex), fo)
  +hv = Equal.trans(S.Value, @X@.EV(@X@.xat_@L@(MAPB_@L@(W), i)), @X@.EV(fbx_@L@(xa)), RT2.v_@E@_bx(RT2.th_@E@_bx(xa)), Equal.cong(@MBX@, S.Value, z => @X@.EV(z), @X@.xat_@L@(MAPB_@L@(W), i), fbx_@L@(xa), ex), fv)
  (FD.logic__and_intro(@X@.EOK(@X@.xat_@L@(MAPB_@L@(W), i)), @X@.EOKS(q, MAPB_@L@(W), 1n+i), ho, io),
    Equal.trans(S.Value, S.Items{@X@.EV(@X@.xat_@L@(MAPB_@L@(W), i)), @X@.XI(q, MAPB_@L@(W), 1n+i)}, S.Items{RT2.v_@E@_bx(RT2.th_@E@_bx(xa)), @X@.XI(q, MAPB_@L@(W), 1n+i)}, S.Items{RT2.v_@E@_bx(RT2.th_@E@_bx(xa)), RT2.xi_@L@(q, W, 1n+i)},
      Equal.cong(S.Value, S.Value, z => S.Items{z, @X@.XI(q, MAPB_@L@(W), 1n+i)}, @X@.EV(@X@.xat_@L@(MAPB_@L@(W), i)), RT2.v_@E@_bx(RT2.th_@E@_bx(xa)), hv),
      Equal.cong(S.Value, S.Value, z => S.Items{RT2.v_@E@_bx(RT2.th_@E@_bx(xa)), z}, @X@.XI(q, MAPB_@L@(W), 1n+i), RT2.xi_@L@(q, W, 1n+i), iv)))
def exs_@L@(k: Nat, +W: List<&2, @MBR@>, +i: Nat, +sE: S.Schema, +er: RT2.ereps_@L@(k, W, i, sE), +ep: EPS_@L@(k, W, i), +es: SFE_@E@(sE)) -> EXS_@L@(k, W, i):
  match k:
    case 0n: ({==}, {==})
    case 1n+ +q:
      (+r0, +er1) = er
      (+p0, +ep1) = ep
      exs2_@L@(q, W, i, efx_@L@(RT2.xat_@L@(W, i), sE, r0, p0, es), exs_@L@(q, W, 1n+i, sE, er1, ep1, es))

# the list's record facts from its mirror's
def MK_@L@(+t: FD.array__Tree<@MBR@>, +N: U32) -> Data:
  DK.P2({@X@.TH(@X@.MW{TM_@L@(t), N}) == @SEQ@{RT2.am_@L@(t), N} : @SEQ@},
  DK.P2({RT2.xv_@L@(@X@.TH(@X@.MW{TM_@L@(t), N})) == @X@.VAL(@X@.MW{TM_@L@(t), N}) : S.Value},
  DK.P2({@X@.OK(@X@.MW{TM_@L@(t), N}) == True{} : Bool}, {Nat.is_le(LY.LN(@X@.ENC(@X@.MW{TM_@L@(t), N})), P1()) == True{} : Bool})))
def mk2_@L@(+t: FD.array__Tree<@MBR@>, +dw: Nat, +N: U32, +pf: {FD.array__perfect(@MBR@, dw, t) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{} : Bool},
    +hd31: {Nat.is_lt(ER.LDEP(@MBR@, t), 31n) == True{} : Bool}, +hll: {Nat.is_le(@X@.LL(TM_@L@(t), N), P1()) == True{} : Bool}, +x: EXS_@L@(U32.to_nat(N), FD.array__slots(@MBR@, t), 0n)) -> MK_@L@(t, N):
  (+xo, +xv) = x
  +T2 = TM_@L@(t)
  +h31 = FD.logic__subst(Nat, z => {Nat.is_lt(z, 31n) == True{} : Bool}, ER.LDEP(@MBR@, t), dw, ER.pdep(@MBR@, dw, t, pf), hd31)
  +td = tdTM_@L@(dw, t, pf)
  +esl = slTM_@L@(t)
  +hx2 = FD.logic__subst(List<&2, @MBX@>, z => {@X@.EOKS(U32.to_nat(N), z, 0n) == True{} : Bool}, MAPB_@L@(FD.array__slots(@MBR@, t)), FD.array__slots(@MBX@, T2), Equal.sym(List<&2, @MBX@>, FD.array__slots(@MBX@, T2), MAPB_@L@(FD.array__slots(@MBR@, t)), esl), xo)
  +okl0 = FD.logic__and_intro(Nat.is_lt(dw, 31n), Bool.and(FD.array__perfect(@MBX@, dw, T2), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(dw)), Bool.and(True{}, @X@.EOKS(U32.to_nat(N), @X@.SL(T2), 0n)))), h31,
    FD.logic__and_intro(FD.array__perfect(@MBX@, dw, T2), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(dw)), Bool.and(True{}, @X@.EOKS(U32.to_nat(N), @X@.SL(T2), 0n))), pfTM_@L@(dw, t, pf),
    FD.logic__and_intro(Nat.is_le(U32.to_nat(N), VB.pw(dw)), Bool.and(True{}, @X@.EOKS(U32.to_nat(N), @X@.SL(T2), 0n)), hN,
    FD.logic__and_intro(True{}, @X@.EOKS(U32.to_nat(N), @X@.SL(T2), 0n), {==}, hx2))))
  +okl = FD.logic__subst(Nat, z => {Bool.and(Nat.is_lt(z, 31n), Bool.and(FD.array__perfect(@MBX@, z, T2), Bool.and(Nat.is_le(U32.to_nat(N), VB.pw(z)), Bool.and(True{}, @X@.EOKS(U32.to_nat(N), @X@.SL(T2), 0n))))) == True{} : Bool},
    dw, @X@.TDM(T2), Equal.sym(Nat, @X@.TDM(T2), dw, td), okl0)
  +ok = FD.logic__and_intro(@X@.OKL(T2, N), Nat.is_le(@X@.LL(T2, N), A.quad(VB.pw(28n))), okl, llq(@X@.LL(T2, N), VB.pw(27n), hll, FD.nat__le_trans(Nat.add(0n, 1n), VB.pw(9n), VB.pw(27n), {==}, VBG.pw_mono(9n, 27n, {==}))))
  +eth = Equal.cong(Array<O.Boxed<@ETY@>>, @SEQ@, z => @SEQ@{z, N}, @X@.AR(T2), RT2.am_@L@(t), arTM_@L@(t))
  +ev = Equal.trans(S.Value, RT2.xv_@L@(@X@.TH(@X@.MW{T2, N})), RT2.xv_@L@(@SEQ@{RT2.am_@L@(t), N}), @X@.VAL(@X@.MW{T2, N}),
    Equal.cong(@SEQ@, S.Value, z => RT2.xv_@L@(z), @X@.TH(@X@.MW{T2, N}), @SEQ@{RT2.am_@L@(t), N}, eth),
    Equal.trans(S.Value, RT2.xv_@L@(@SEQ@{RT2.am_@L@(t), N}), S.Sequence{RT2.xi_@L@(U32.to_nat(N), FD.array__slots(@MBR@, t), 0n)}, @X@.VAL(@X@.MW{T2, N}),
      Equal.cong(FD.array__Tree<@MBR@>, S.Value, z => S.Sequence{RT2.xi_@L@(U32.to_nat(N), FD.array__slots(@MBR@, z), 0n)}, RT2.tfz_@L@(RT2.am_@L@(t)), t, RT2.tfzam_@L@(t)),
      Equal.trans(S.Value, S.Sequence{RT2.xi_@L@(U32.to_nat(N), FD.array__slots(@MBR@, t), 0n)}, S.Sequence{@X@.XI(U32.to_nat(N), MAPB_@L@(FD.array__slots(@MBR@, t)), 0n)}, @X@.VAL(@X@.MW{T2, N}),
        Equal.cong(S.Value, S.Value, z => S.Sequence{z}, RT2.xi_@L@(U32.to_nat(N), FD.array__slots(@MBR@, t), 0n), @X@.XI(U32.to_nat(N), MAPB_@L@(FD.array__slots(@MBR@, t)), 0n),
          Equal.sym(S.Value, @X@.XI(U32.to_nat(N), MAPB_@L@(FD.array__slots(@MBR@, t)), 0n), RT2.xi_@L@(U32.to_nat(N), FD.array__slots(@MBR@, t), 0n), xv)),
        Equal.cong(List<&2, @MBX@>, S.Value, z => S.Sequence{@X@.XI(U32.to_nat(N), z, 0n)}, MAPB_@L@(FD.array__slots(@MBR@, t)), FD.array__slots(@MBX@, T2), Equal.sym(List<&2, @MBX@>, FD.array__slots(@MBX@, T2), MAPB_@L@(FD.array__slots(@MBR@, t)), esl)))))
  +ln = FD.logic__subst(Nat, z => {Nat.is_le(z, P1()) == True{} : Bool}, @X@.LL(T2, N), LY.LN(@X@.ENC(@X@.MW{T2, N})), Equal.sym(Nat, LY.LN(@X@.ENC(@X@.MW{T2, N})), @X@.LL(T2, N), @X@.len_encl(T2, N)), hll)
  (eth, (ev, (ok, ln)))
def mk_@L@(+t: FD.array__Tree<@MBR@>, +dw: Nat, +N: U32, +sE: S.Schema, +pf: {FD.array__perfect(@MBR@, dw, t) == True{} : Bool}, +hN: {Nat.is_le(U32.to_nat(N), FD.spec_common__pow2(dw)) == True{} : Bool},
    +er: RT2.ereps_@L@(U32.to_nat(N), FD.array__slots(@MBR@, t), 0n, sE), +pm: PM_@L@(t, N), +es: SFE_@E@(sE)) -> MK_@L@(t, N):
  (+hd31, +pq) = pm
  (+hll, +eps) = pq
  mk2_@L@(t, dw, N, pf, hN, hd31, hll, exs_@L@(U32.to_nat(N), FD.array__slots(@MBR@, t), 0n, sE, er, eps, es))

# the field's record from its root-law representation and premise
def LRV_@L@(o: @SEQ@) -> Data:
  DK.Ex(@X@.MW, m => DK.P2({o == @X@.TH(m) : @SEQ@}, DK.P2({RT2.xv_@L@(@X@.TH(m)) == @X@.VAL(m) : S.Value}, DK.P2({@X@.OK(m) == True{} : Bool}, {Nat.is_le(LY.LN(@X@.ENC(m)), P1()) == True{} : Bool}))))
def rv3_@L@(-o: @SEQ@, +t: FD.array__Tree<@MBR@>, +N: U32, +eo: {o == @SEQ@{RT2.am_@L@(t), N} : @SEQ@}, +mk: MK_@L@(t, N)) -> LRV_@L@(o):
  (+eth, +m1) = mk
  (+ev, +m2) = m1
  (+ok, +ln) = m2
  (@X@.MW{TM_@L@(t), N}, (Equal.trans(@SEQ@, o, @SEQ@{RT2.am_@L@(t), N}, @X@.TH(@X@.MW{TM_@L@(t), N}), eo, Equal.sym(@SEQ@, @X@.TH(@X@.MW{TM_@L@(t), N}), @SEQ@{RT2.am_@L@(t), N}, eth)), (ev, (ok, ln))))
def rv_@L@(-o: @SEQ@, +s: S.Schema, +rp: RT2.rep_@L@(o, s), +hp: PRV_@L@(o), +es: SFE_@E@(SH.ProgressiveList_element(s))) -> LRV_@L@(o):
  (+t, +r1) = rp
  (+dw, +r2) = r1
  (+N, +r3) = r2
  (+eo, +r4) = r3
  (+pf, +r5) = r4
  (+hd32, +r6) = r5
  (+hN, +er) = r6
  +hp2 = FD.logic__subst(@SEQ@, z => PRV_@L@(z), o, @SEQ@{RT2.am_@L@(t), N}, eo, hp)
  +hp3 = FD.logic__subst(FD.array__Tree<@MBR@>, z => PM_@L@(z, N), RT2.tfz_@L@(RT2.am_@L@(t)), t, RT2.tfzam_@L@(t), hp2)
  rv3_@L@(o, t, N, eo, mk_@L@(t, dw, N, SH.ProgressiveList_element(s), pf, hN, er, hp3, es))
"""


def _encl_vl(L):
    fn, X, E, EMA, ETY, LD = ENCL_VL[L]
    return (ENCL_VL_PER.replace('@MBR@', f'RT2.MB<RT2.M_{E}>').replace('@MBX@', f'{X}.MB<{EMA}.MW>').replace('@SEQ@', f'{LD}.{L}_Seq')
            .replace('@ETY@', ETY).replace('@EMA@', EMA).replace('@X@', X).replace('@E@', E).replace('@L@', L))


def encl_text():
    body = [ENCL_A, ENCL_RL_SHARED]
    imps = []
    for T in ENCL_RL:
        txt, im = _encl_rl(T)
        body.append(txt)
        imps += [i for i in im if i not in imps]
    body += [ENCL_VL_SHARED, _encl_vl('pl_Gc465214E502'), ENCL_VL_PL, _encl_vl('pl_pl_Gc465214E502'), ENCL_VL_G, _encl_vl('pl_Gp66304057C3')]
    for fn, al in [('big_encx_pl_Gc465214E502', 'XA'), ('big_encx_pl_pl_Gc465214E502', 'XB'), ('big_encx_Gc465214E502_iface', 'XVT'), ('big_encx_l1024_u16', 'Xl1024'),
                   ('big_encx_pl_Gp66304057C3', 'XC'), ('big_encx_Gp66304057C3_iface', 'CIG'), ('big_encx_l123_u16', 'Xl123'), ('big_encx_pbits', 'EXP'), ('bitlist_obj', 'BO')]:
        imps.append(f'import ../proofs/obj/{fn}.bend as {al}')
    imps += ['import ./e2e_encp.bend as EP', 'import ../types/VarTestStruct_def_generated.bend as VarTestStruct_d',
             'import ../types/proglist_VarTestStruct_def_generated.bend as proglist_VarTestStruct_d',
             'import ../types/proglist_proglist_VarTestStruct_def_generated.bend as proglist_proglist_VarTestStruct_d',
             'import ./e2e_encq.bend as EQ', 'import ../types/ProgressiveVarTestStruct_def_generated.bend as ProgressiveVarTestStruct_d',
             'import ../types/proglist_ProgressiveVarTestStruct_def_generated.bend as proglist_ProgressiveVarTestStruct_d']
    head = ['import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/nat_order.bend as Order',
            'import ../proofs/obj/vbuf.bend as VB', 'import ../proofs/obj/vbig.bend as VBG', 'import ../proofs/obj/vbytes.bend as VY',
            'import ../proofs/obj/vua_lay.bend as LY', 'import ../proofs/obj/vua.bend as UA', 'import ../proofs/obj/vua_rd.bend as UR',
            'import ../proofs/obj/vua_fix.bend as VTX', 'import ../proofs/obj/vspec.bend as VS', 'import ../proofs/obj/vcopy.bend as VC',
            'import ../proofs/obj/vdepth.bend as VD', 'import ../proofs/obj/vlist.bend as VLS', 'import ../proofs/obj/venc.bend as VEN',
            'import ../proofs/obj/words_obj.bend as WO', 'import ../proofs/obj/packed_bytes.bend as PBF', 'import ../proofs/obj/pb_min.bend as PBM',
            'import ../proofs/obj/ulist_obj.bend as UL', 'import ../proofs/obj/vu32.bend as VU', 'import ../proofs/obj/dk.bend as DK',
            'import ../proofs/obj/list_obj.bend as LO', 'import ../proofs/obj/vrl.bend as VRL', 'import ../proofs/obj/vrecx.bend as VRX',
            'import ../proofs/obj/vrecb.bend as VRB', 'import ../proofs/obj/len_bridge.bend as LB', 'import ../proofs/obj/vbitb.bend as VBB',
            'import ../proofs/obj/schema_shapes.bend as SH', 'import ../proofs/obj/root_gtypes2.bend as RT2', 'import ../proofs/obj/root_gnames.bend as RN',
            'import ../types/uint8_encode_ssz_generated.bend as uint8_e', 'import ../types/uint16_encode_ssz_generated.bend as uint16_e',
            'import ../proofs/obj/big_encx_pl_u8.bend as XU8', 'import ../proofs/obj/big_encx_pl_u64.bend as XU64',
            'import ../proofs/obj/big_var_winp_u8.bend as PU8', 'import ../proofs/obj/big_var_winp_pl_u64.bend as PU64',
            'import ./e2e_encr.bend as ER', 'import ./e2e_blist.bend as BL', 'import ./e2e_plist.bend as PL', 'import ./e2e_ulist.bend as ULW',
            'import ./e2e_gprog.bend as GP', 'import ./e2e_gwin.bend as GW'] + imps
    return '\n'.join(head) + '''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# Encode records from the root law's representation for the progressive containers' list fields: a record
# X.MW whose object is the field, whose view is the record's value, valid, and whose bytes are bounded (P1 =
# 2^27 + 1 for an unbounded list: the premise; a limit's bytes for a limited one). Byte storage (pu8, pu64),
# record lists (rb_T).

''' + '\n'.join(body)


SUPPORT_OUT['e2e_encl.bend'] = encl_text()


def prog_view(R, X, mod='e2e_gprog'):
    """(ii)/(iii) of a progressive container: its window view (<mod>.vw_X) at the whole buffer."""
    text = f'''# ---- the view of a decoded object is the codec law's value ({mod}.vw_{X} at the window (0, 0, n)) ----
def vv(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {{FD.array__perfect(U32, d, t) == True{{}} : Bool}}, +hd: {{Nat.is_lt(d, @BD@) == True{{}} : Bool}},
    +hn: {{Nat.is_le(U32.to_nat(n), A.quad(FD.spec_common__pow2(d))) == True{{}} : Bool}}, +hchk: {{DC.CHK(t, n) == True{{}} : Bool}}) -> {{RT.v_{X}(DC.OBJ(d, t, n)) == DC.VAL(t, n) : S.Value}}:
  GP.vw_{X}(d, t, n, 0n, 0, n, {{==}}, hd, hn, pf, hchk)

'''
    return {'view': f'RT.v_{X}', 'imports': ['import ../proofs/obj/root_gtypes2.bend as RT', f'import ./{mod}.bend as GP'], 'text': text}


VDEC_VIEWS['Gp4B0CA2906A'] = prog_view('ProgressiveSingleListContainerTestStruct', 'Gp4B0CA2906A')
VDEC_VIEWS['Gp66304057C3'] = prog_view('ProgressiveVarTestStruct', 'Gp66304057C3')
VDEC_VIEWS['Gc221EC01D83'] = prog_view('ProgressiveTestStruct', 'Gc221EC01D83', 'e2e_gcx')
VDEC_VIEWS['Gp8A7851175B'] = prog_view('ProgressiveComplexTestStruct', 'Gp8A7851175B', 'e2e_gcx')
VDEC_VIEWS['GuAD91DEB870'] = union_view('CompatibleUnionBC', 'GuAD91DEB870')
VDEC_VIEWS['Gu6DDF182530'] = union_view('CompatibleUnionABCA', 'Gu6DDF182530')


CPX['Gp4B0CA2906A'] = {'mods': ['ProgressiveSingleListContainerTestStruct_d:ProgressiveSingleListContainerTestStruct_def_generated'],
                       'hmod': 'ProgressiveSingleListContainerTestStruct_h:ProgressiveSingleListContainerTestStruct_hashtreeroot_generated',
                       'rt': 'root_gtypes2', 'gv': 'gvalid_gtypes2', 'fields': [('b', 'O.Bits')]}
CPX['Gp66304057C3'] = {'mods': ['ProgressiveVarTestStruct_d:ProgressiveVarTestStruct_def_generated'],
                       'hmod': 'ProgressiveVarTestStruct_h:ProgressiveVarTestStruct_hashtreeroot_generated',
                       'rt': 'root_gtypes2', 'gv': 'gvalid_gtypes2', 'fields': [('u', 'U32'), ('l', 'O.Words'), ('b', 'O.Bits')]}
VROOT_SHAPES['Gp4B0CA2906A'] = vroot_complex
VROOT_SHAPES['Gp66304057C3'] = vroot_complex


# ==== e2e_gcp: a root-law object rebuilt from its rep's witnesses (for the root law's runtime argument) ====
# cp_X(o, s, rep): the Data witnesses of each projected field (u: the U32, l: words' tree and length,
# b: bits' tree and count) and o == the literal they build (CPT_X). Used by (iv) of unions whose arms are
# Type-kinded containers.
GCP_NAMES = ['Gp4B0CA2906A', 'Gp66304057C3']


def cp_lit(X):
    fs = CPX[X]['fields']
    shp = [_cp_shape(kd, T, k) for k, (kd, T) in enumerate(fs)]
    return [v for vs, _ in shp for v in vs], f'T.{X}{{{", ".join(lit for _, lit in shp)}}}', shp


def gcp_text():
    WL = 'O.Words{FD.array__thaw(U32, t), N}'
    wsig = [('t', 'FD.array__Tree<U32>'), ('N', 'U32')]
    L = [f'''def cpw(-w: O.Words, +wf: LO.wfl(w)) -> {_ex(wsig, f'{{w == {WL} : O.Words}}')}:
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

def cpb(-w: O.Bits, +wf: BO.wfb(w)) -> {_ex(wsig, '{w == O.Bits{FD.array__thaw(U32, t), N} : O.Bits}')}:
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
''']
    for X in GCP_NAMES:
        D = f'T.{X}'
        fs = CPX[X]['fields']
        n = len(fs)
        allv, OL, shp = cp_lit(X)
        PJ = lambda k: f'RT.pj_{X}_{k}(o)'  # noqa: E731
        us = [k for k, (kd, _) in enumerate(fs) if kd == 'u']
        cps = [(k, T) for k, (kd, T) in enumerate(fs) if kd != 'u']
        cur = [f'x{k}' if kd == 'u' else PJ(k) for k, (kd, _) in enumerate(fs)]
        E0 = f'{D}{{{", ".join(cur)}}}'
        eqn = 'eo'
        for k, T in cps:
            nxt = list(cur)
            nxt[k] = shp[k][1]
            mot = list(cur)
            mot[k] = 'z'
            eqn = (f'Equal.trans({D}, o, {D}{{{", ".join(cur)}}}, {D}{{{", ".join(nxt)}}},\n    {eqn},\n    '
                   f'Equal.cong({T}, {D}, z => {D}{{{", ".join(mot)}}}, {PJ(k)}, {shp[k][1]}, e{k}))')
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
        uparams = ''.join(f'+x{k}: U32, ' for k in us)
        lines, src = [], 'rep'
        for i, k in enumerate(us):
            lines.append(f'  (+x{k}, +r{i}) = {src}')
            src = f'r{i}'
        lines.append(f'  (+eo, +q0) = {src}')
        pn = {i: (f'q{i}' if i == n - 1 else f'p{i}') for i in range(n)}
        for i in range(n):
            if i < n - 1:
                lines.append(f'  (+p{i}, +q{i + 1}) = q{i}')
            if fs[i][0] == 'l':
                lines.append(f'  (+wf{i}, +z{i}) = {pn[i]}')
        args = [f'cpw({PJ(k)}, wf{k})' if fs[k][0] == 'l' else f'cpb({PJ(k)}, {pn[k]})' for k, _ in cps]
        lines.append(f'  cc_{X}(o, {"".join("x" + str(k) + ", " for k in us)}eo, ' + ', '.join(args) + ')')
        L.append(f'''# ---- {X} ----
def CPT_{X}(o: {D}) -> Data: {_ex(allv, f'{{o == {OL} : {D}}}')}

def cc_{X}(-o: {D}, {uparams}+eo: {{o == {E0} : {D}}}, {cparams}) -> CPT_{X}(o):
{chr(10).join(unp)}
  {_tup(allv, eqn)}

def cp_{X}(-o: {D}, +s: S.Schema, +rep: RT.rep_{X}(o, s)) -> CPT_{X}(o):
{chr(10).join(lines)}
''')
    head = ['import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/generic_obj.bend as T',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/obj/dk.bend as DK', 'import ../proofs/obj/list_obj.bend as LO',
            'import ../proofs/obj/bitlist_obj.bend as BO', 'import ../proofs/obj/root_gtypes2.bend as RT']
    return '\n'.join(head) + '''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# A root-law object rebuilt from its rep's witnesses: cp_X(o, s, rep) gives each projected field's Data
# witnesses and o == the literal they build (the root law takes its object at runtime).

''' + '\n'.join(L)


SUPPORT_OUT['e2e_gcp.bend'] = gcp_text()


def vroot_union_n(R, X, rt='root_gtypes2', gv='gvalid_gtypes2'):
    """(iv) of a CompatibleUnion with any arms: rep is an Or2 tree (por_X_i) over the arms' pc_X_k. A Data
    arm (pc: DK.Ex v, o == ck{v}) is its value; a Type arm (pc: o == ck{pju(o)}, the arm's rep) is rebuilt
    from its rep (e2e_gcp.cp_Arm)."""
    vsrc = _unlight((ROOT / f'proofs/obj/{rt}.bend').read_text())
    pcs = dict((int(k), b) for k, b in re.findall(rf'^def pc_{X}_(\d+)\(o: .*?\) -> Data: (.*)$', vsrc, re.M))
    arms = sorted(pcs)
    D = f'T.{X}'
    RX = lambda o: f'D.bytes(Pair.snd({D}, D.Digest, Pair.snd(B.Buf, {D} & D.Digest, T.{X}_hash_tree_root(h, {o}))))'  # noqa: E731
    G = lambda o: f'{{Some{{{RX(o)}}} == API.hash_tree_root(Spec.{X}(), RT.v_{X}({o})) : Maybe<&2, +List<U32>>}}'  # noqa: E731
    L = []
    for k in arms:
        b = pcs[k]
        m = re.match(r'DK\.Ex\((\w+)\.(\w+), v =>', b)
        if m:
            ty = f'T.{m.group(2)}'
            lit, wp, wa = f'{D}_c{k}{{v}}', f'+v: {ty}', 'v'
            handler = f'''  (+v, +q) = pc
  (+eo, +rp) = q
  rt2_{k}(h, o, rep, v, eo)'''
            extra = ''
        else:
            m2 = re.match(rf'DK\.P2\(\{{o == \w+\.{X}_c{k}\{{pju_{X}_{k}\(o\)\}} : \S+\}}, rep_(\w+)\(pju_{X}_{k}\(o\), (.*)\)\)$', b)
            A, sch = m2.group(1), m2.group(2)
            allv, OLa, _ = cp_lit(A)
            lit = f'{D}_c{k}{{{OLa}}}'
            wp = ', '.join(f'+{v}: {T}' for v, T in allv)
            wa = ', '.join(v for v, _ in allv)
            PJU = f'RT.pju_{X}_{k}(o)'
            extra = f'''def ak{k}(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o), +eo: {{o == {D}_c{k}{{{PJU}}} : {D}}}, +c: GC.CPT_{A}({PJU})) -> {G('o')}:
{chr(10).join(f"  (+{v}, +c{i}) = {'c' if i == 0 else f'c{i - 1}'}" for i, (v, _) in enumerate(allv))}
  rt2_{k}(h, o, rep, {wa}, Equal.trans({D}, o, {D}_c{k}{{{PJU}}}, {lit}, eo, Equal.cong(T.{A}, {D}, z => {D}_c{k}{{z}}, {PJU}, {OLa}, c{len(allv) - 1})))
'''
            handler = f'''  (+eo, +ra) = pc
  ak{k}(h, o, rep, eo, GC.cp_{A}({PJU}, {sch}, ra))'''
        L.append(f'''def rt1_{k}(h: B.Buf, {wp}, +rep: RT.rep_{X}({lit})) -> {G(lit)}:
  E.root_legal(Spec.{X}(), RT.v_{X}({lit}), VS.public_sound(Spec.{X}(), {{==}}), {RX(lit)},
    GV.{X}_root_valid({lit}, rep), RT.{X}_root_correct(h, {lit}, rep))

def rt2_{k}(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o), {wp}, +eo: {{o == {lit} : {D}}}) -> {G('o')}:
  %Equal.sym({D}, o, {lit}, eo) : {G('_')}
  rt1_{k}(h, {wa}, FD.logic__subst({D}, z => RT.rep_{X}(z), o, {lit}, eo, rep))

{extra}def arm{k}(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o), +pc: RT.pc_{X}_{k}(o)) -> {G('o')}:
{handler}
''')
    pors = sorted(int(i) for i in re.findall(rf'^def por_{X}_(\d+)\(', vsrc, re.M))
    for i in reversed(pors):
        b = re.search(rf'^def por_{X}_{i}\(o: .*?\) -> Data: DK\.Or2\((\w+)_{X}_(\d+)\(o\), (\w+)_{X}_(\d+)\(o\)\)$', vsrc, re.M)
        call = lambda kind, j, a: f'arm{j}(h, o, rep, {a})' if kind == 'pc' else f'por{j}(h, o, rep, {a})'  # noqa: E731
        L.append(f'''def por{i}(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o), +r: RT.por_{X}_{i}(o)) -> {G('o')}:
  match r:
    case Inl{{a}}: {call(b.group(1), b.group(2), 'a')}
    case Inr{{b}}: {call(b.group(3), b.group(4), 'b')}
''')
    body = '  por0(h, o, rep, rep)' if pors else '  arm0(h, o, rep, rep)'
    imps = ['import Base', 'import ../END_TO_END.bend as E2E', 'import ../src/model.bend as API', 'import ../src/buffer.bend as B',
            'import ../src/digest.bend as D', 'import ../src/obj.bend as O', 'import ../types/generic_obj.bend as T', 'import ../types/schema.bend as S',
            'import ../proofs/obj/generic_specs.bend as Spec', 'import ../proofs/type_validator_soundness.bend as VS', 'import ../proofs/compact/found.bend as FD',
            f'import ../proofs/obj/{rt}.bend as RT', f'import ../proofs/obj/{gv}.bend as GV', 'import ../proofs/obj/dk.bend as DK', 'import ./e2e_support.bend as E',
            'import ./e2e_gcp.bend as GC', 'import ../types/primitive.bend as P']
    return '\n'.join(imps) + f"""

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# {R} (a CompatibleUnion): the object API's root is END_TO_END's hash_tree_root, for every object the
# root law represents (rep_{X}: the selected arm's value, represented; a container arm rebuilt from its rep).

""" + '\n'.join(L) + f"""
# (iv)
def {R}_e2e_root(h: B.Buf, -o: {D}, +rep: RT.rep_{X}(o)) -> {G('o')}:
{body}
"""


VROOT_SHAPES['GuAD91DEB870'] = vroot_union_n
VROOT_SHAPES['Gu6DDF182530'] = vroot_union_n


# ==== e2e_encp: a progressive bit list's encode record from the root law's representation ====
# The record EXP.MB{dw, T, K, B, kb, KY} takes B = K and the widths kb, KY at their bounds (kb < 32, KY < 31
# in its OKT). Its premise SDPB carries what the root law's wfb does not: the storage depth below the law's
# bound, the widths' conditions at B = K, the delimiter word's room ((K >> 5) + 1 words) and the bits above
# K zero in word K >> 5; wfb gives the rest (HZ: vbitrep.rep_hz; the zero bytes past the last: e2e_tz.tz).
def encp_text():
    okt = _okt(_obj('big_encx_pbits.bend'))
    Kd = int(re.search(r'Nat\.is_lt\(dw, (\d+)n\)', okt).group(1))
    KB0 = int(re.search(r'Nat\.is_lt\(kb, (\d+)n\)', okt).group(1)) - 1
    KB = min(KB0, 31)   # the bridge's width: 31 (its premise 31 + K + 1 <= 2^30 bounds K anyway)
    # the record no longer bounds KY (vbitenc.y30); the bridge keeps its own 31 + K + 1 <= 2^30 premise for
    # the container's output bound (PBR), with the record's KY field at 30
    mKY = re.search(r'Nat\.is_lt\(KY, (\d+)n\)', okt)
    KY = int(mKY.group(1)) - 1 if mKY else 30
    TR = 'FD.array__Tree<U32>'
    OBT = 'O.Bits{FD.array__thaw(U32, T), K}'
    subst = lambda t: re.sub(r'\bKY\b', f'{KY}n', re.sub(r'\bkb\b', f'{KB}n', re.sub(r'\bB\b', 'U32.to_nat(K)', t)))  # noqa: E731
    o2 = subst(okt)
    conj = {
        'FD.array__perfect(U32, dw, T)': 'pf', f'Nat.is_lt(dw, {Kd}n)': 'hdw', f'Nat.is_lt({KB}n, {KB0 + 1}n)': '{==}', f'Nat.is_lt({KY}n, {KY + 1}n)': '{==}',
        'Nat.is_le(U32.to_nat(K), U32.to_nat(K))': 'hN', f'Nat.is_le(Nat.add(U32.to_nat(K), 8n), O.pow2n({KB}n))': 'hK8',
        f'Nat.is_le(Nat.add(31n, Nat.add(U32.to_nat(K), 1n)), VB.pw({KY}n))': 'hKY', 'Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw))': 'hroom',
        'O.tail_zero(U32.and(O.bits_nbytes(K), 3), VB.slot(T, VY.QL(O.bits_nbytes(K))))': 'htz', 'DL.HZ(DL.RK(K), VB.slot(T, VBT.QK(K)))': 'hz',
        'O.bits_above_zero(U32.and(K, 31), RD.wd(T, dw, U32.shrn(K, 5n)))': 'hbz', 'True{}': '{==}'}
    HOK = _andproof(o2, conj)
    prem = [f'{{FD.array__perfect(U32, dw, T) == True{{}} : Bool}}', '{Nat.is_lt(dw, Kd) == True{} : Bool}',
            f'{{Nat.is_le(Nat.add(U32.to_nat(K), 8n), O.pow2n({KB}n)) == True{{}} : Bool}}',
            f'{{Nat.is_le(Nat.add(31n, Nat.add(U32.to_nat(K), 1n)), VB.pw({KY}n)) == True{{}} : Bool}}',
            '{Nat.is_le(Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), VB.pw(dw)) == True{} : Bool}',
            '{O.bits_above_zero(U32.and(K, 31), RD.wd(T, dw, U32.shrn(K, 5n))) == True{} : Bool}']
    body = prem[-1]
    for p in reversed(prem[:-1]):
        body = f'DK.P2({p},\n    {body})'
    P27 = KY - 3
    return f'''import Base
import ../src/obj.bend as O
import ../types/schema.bend as S
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/compact/reads.bend as RD
import ../proofs/nat_order.bend as Order
import ../spec/primitives.bend as SP
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vbig.bend as VBG
import ../proofs/obj/vdepth.bend as VD
import ../proofs/obj/vlist.bend as VL
import ../proofs/obj/vbytes.bend as VY
import ../proofs/obj/vbitenc.bend as VBT
import ../proofs/obj/vbitdl.bend as DL
import ../proofs/obj/vbitcore.bend as CO
import ../proofs/obj/vbitrep.bend as VBR
import ../proofs/obj/vua_lay.bend as LY
import ../proofs/obj/words_spec.bend as WS
import ../proofs/obj/bitlist_obj.bend as BO
import ../proofs/obj/bitlist_pack.bend as BK
import ../proofs/obj/dk.bend as DK
import ../proofs/obj/big_encx_pbits.bend as EXP
import ./e2e_tz.bend as TZ
import ./e2e_bitl.bend as BLB
import ./e2e_cap.bend as C

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# A progressive bit list's encode record from the root law's representation: EXP.MB{{dw, T, K, K, {KB}, {KY}}},
# valid under its premise SDPB (what the root law's wfb does not give; see codegen/e2e_var_c.py: encp_text).

def SDPB(o: O.Bits, +Kd: Nat) -> Data:
  DK.Ex({TR}, T => DK.Ex(Nat, dw => DK.Ex(U32, K => DK.P2({{o == {OBT} : O.Bits}},
    {body}))))

# the bytes past the list's last byte are zero in its last word (wfb1's zero padding; nothing when empty)
def pbtz(+T: {TR}, +K: U32, +wf: BO.wfb({OBT})) -> {{O.tail_zero(U32.and(O.bits_nbytes(K), 3), VB.slot(T, VY.QL(O.bits_nbytes(K)))) == True{{}} : Bool}}:
  match wf:
    case Inl{{+a}}:
      (+t, +a1) = a
      (+dw2, +a2) = a1
      (+K2, +a3) = a2
      (+eo, +a4) = a3
      (+pf2, +a5) = a4
      (+hd2, +e0) = a5
      +eK = VBR.eK_of(T, K, t, K2, eo)
      +e0K = FD.logic__subst(U32, z => {{U32.to_nat(z) == 0n : Nat}}, K2, K, Equal.sym(U32, K, K2, eK), e0)
      FD.logic__subst(U32, z => {{O.tail_zero(U32.and(O.bits_nbytes(z), 3), VB.slot(T, VY.QL(O.bits_nbytes(z)))) == True{{}} : Bool}}, 0, K, Equal.sym(U32, K, 0, FD.u32__injective(K, 0, e0K)), {{==}})
    case Inr{{+b}}:
      (+t, +b1) = b
      (+dw2, +b2) = b1
      (+K2, +b3) = b2
      (+Q, +b4) = b3
      (+R, +b5) = b4
      (+eo, +b6) = b5
      (+pf2, +b7) = b6
      (+hd2, +b8) = b7
      (+hnb, +b9) = b8
      (+hR0, +b10) = b9
      (+hR32, +b11) = b10
      (+hcq, +b12) = b11
      (+hpad, +b13) = b12
      (+hzt, +b14) = b13
      +eT = VBR.eT_of(T, K, t, K2, eo)
      +eK = VBR.eK_of(T, K, t, K2, eo)
      +hnb2 = FD.logic__subst(U32, z => {{U32.to_nat(O.bits_nbytes(z)) == Nat.add(WS.e32(Q), R) : Nat}}, K2, K, Equal.sym(U32, K, K2, eK), hnb)
      +hpad2 = FD.logic__subst({TR}, z => {{WS.bdrop(R, WS.cb(FD.array__slots(U32, z), Nat.add(Q, 0n))) == SP.zero_bytes(Nat.sub(32n, R)) : +List<U32>}}, t, T, Equal.sym({TR}, T, t, eT), hpad)
      TZ.tz(T, O.bits_nbytes(K), Q, R, hnb2, hR0, hR32, hpad2)

# s_rng(3, 2^(3 + j)) = 2^j
def s3pw(+j: Nat) -> {{VD.s_rng(3n, VB.pw(3n+j)) == VB.pw(j) : Nat}}:
  %Equal.sym(Nat, VD.s_rng(2n, VB.pw(2n+(1n+j))), VB.pw(1n+j), VL.rp(1n+j)) : {{VD.s_h2(_) == VB.pw(j) : Nat}}
  VL.hd2(VB.pw(j))

# c + x <= 4 (2 P) for x <= P + 1 and c + 1 <= P (P symbolic: a closed power is never let-bound)
def bnd(+c: Nat, +x: Nat, +P: Nat, +hx: {{Nat.is_le(x, Nat.add(P, 1n)) == True{{}} : Bool}}, +hc: {{Nat.is_le(Nat.add(c, 1n), P) == True{{}} : Bool}})
    -> {{Nat.is_le(Nat.add(c, x), A.quad(Nat.double(P))) == True{{}} : Bool}}:
  +h1 = FD.nat__le_add_left(x, Nat.add(P, 1n), c, hx)
  +e1 = Equal.trans(Nat, Nat.add(c, Nat.add(P, 1n)), Nat.add(c, Nat.add(1n, P)), Nat.add(Nat.add(c, 1n), P),
    Equal.cong(Nat, Nat, z => Nat.add(c, z), Nat.add(P, 1n), Nat.add(1n, P), FD.nat__add_comm(P, 1n)), Equal.sym(Nat, Nat.add(Nat.add(c, 1n), P), Nat.add(c, Nat.add(1n, P)), FD.nat__add_assoc(c, 1n, P)))
  +h2 = FD.logic__subst(Nat, z => {{Nat.is_le(z, Nat.add(P, P)) == True{{}} : Bool}}, Nat.add(Nat.add(c, 1n), P), Nat.add(c, Nat.add(P, 1n)), Equal.sym(Nat, Nat.add(c, Nat.add(P, 1n)), Nat.add(Nat.add(c, 1n), P), e1),
    Order.add_right(Nat.add(c, 1n), P, P, hc))
  +h3 = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(c, Nat.add(P, 1n)), z) == True{{}} : Bool}}, Nat.add(P, P), Nat.double(P), Equal.sym(Nat, Nat.double(P), Nat.add(P, P), FD.lru_nat_algebra__double_self(P)), h2)
  FD.nat__le_trans(Nat.add(c, x), Nat.add(c, Nat.add(P, 1n)), A.quad(Nat.double(P)), h1,
    FD.nat__le_trans(Nat.add(c, Nat.add(P, 1n)), Nat.double(P), A.quad(Nat.double(P)), h3,
      FD.nat__le_trans(Nat.double(P), Nat.double(Nat.double(P)), A.quad(Nat.double(P)), FD.nat__double_self_le(Nat.double(P)), FD.nat__double_self_le(Nat.double(Nat.double(P))))))

def PBR(w: O.Bits) -> Data:
  DK.Ex(EXP.MB, m => DK.P2({{w == EXP.TH(m) : O.Bits}}, DK.P2({{S.BitsValue{{BO.bview(EXP.TH(m))}} == EXP.VAL(m) : S.Value}},
    DK.P2({{EXP.OK(m) == True{{}} : Bool}}, {{Nat.is_le(LY.LN(EXP.ENC(m)), Nat.add(VB.pw({P27}n), 1n)) == True{{}} : Bool}}))))

def pbv2(+dw: Nat, +T: {TR}, +K: U32) -> {{S.BitsValue{{BO.bview({OBT})}} == EXP.VAL(EXP.MB{{dw, T, K, U32.to_nat(K), {KB}n, {KY}n}}) : S.Value}}:
  %Equal.sym({TR}, FD.array__freeze(U32, FD.array__thaw(U32, T)), T, FD.array__freeze_thaw(U32, T)) :
    {{S.BitsValue{{BK.btk(U32.to_nat(K), BK.bitsof(FD.array__slots(U32, _)))}} == EXP.VAL(EXP.MB{{dw, T, K, U32.to_nat(K), {KB}n, {KY}n}}) : S.Value}}
  {{==}}

# the record EXP.MB{{dw, T, K, K, KB, KY}}: its view, validity and byte bound
def PBF3(+dw: Nat, +T: {TR}, +K: U32) -> Data:
  DK.P2({{S.BitsValue{{BO.bview({OBT})}} == EXP.VAL(EXP.MB{{dw, T, K, U32.to_nat(K), {KB}n, {KY}n}}) : S.Value}},
    DK.P2({{EXP.OK(EXP.MB{{dw, T, K, U32.to_nat(K), {KB}n, {KY}n}}) == True{{}} : Bool}}, {{Nat.is_le(LY.LN(EXP.ENC(EXP.MB{{dw, T, K, U32.to_nat(K), {KB}n, {KY}n}})), Nat.add(VB.pw({P27}n), 1n)) == True{{}} : Bool}}))

def pbf(+T: {TR}, +dw: Nat, +K: U32, +pf: {prem[0]}, +hdw: {{Nat.is_lt(dw, {Kd}n) == True{{}} : Bool}},
    +hK8: {prem[2]}, +hKY: {prem[3]}, +hroom: {prem[4]}, +hbz: {prem[5]}, +wf: BO.wfb({OBT})) -> PBF3(dw, T, K):
  +N = U32.to_nat(K)
  +hN = FD.nat__le_refl(N)
  +tq = CO.eq5(K, {KB}n, N, {{==}}, hN, hK8)
  +hr1 = FD.logic__subst(Nat, z => {{Nat.is_le(z, VB.pw(dw)) == True{{}} : Bool}}, Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), 1n+U32.to_nat(U32.shrn(K, 5n)), FD.nat__add_comm(U32.to_nat(U32.shrn(K, 5n)), 1n), hroom)
  +hqs = FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(dw)) == True{{}} : Bool}}, U32.to_nat(U32.shrn(K, 5n)), VBT.QK(K), tq, FD.nat__succ_le_lt(U32.to_nat(U32.shrn(K, 5n)), VB.pw(dw), hr1))
  +hz = VBR.rep_hz(dw, T, K, {KB}n, N, pf, {{==}}, hN, hK8, hqs, wf)
  +htz = pbtz(T, K, wf)
  +hok = {HOK}
  +hNle = FD.nat__le_trans(N, Nat.add(N, 1n), VB.pw({KY}n), FD.nat__le_add_right(N, 1n), FD.nat__le_trans(Nat.add(N, 1n), Nat.add(31n, Nat.add(N, 1n)), VB.pw({KY}n), Order.left_below_sum(31n, Nat.add(N, 1n)), hKY))
  +hs3 = FD.logic__subst(Nat, z => {{Nat.is_le(VD.s_rng(3n, N), z) == True{{}} : Bool}}, VD.s_rng(3n, VB.pw(3n+{P27}n)), VB.pw({P27}n), s3pw({P27}n), C.rgm(3n, N, VB.pw({KY}n), hNle))
  +hnk = FD.nat__le_trans(U32.to_nat(CO.NK(K)), Nat.add(VD.s_rng(3n, N), 1n), Nat.add(VB.pw({P27}n), 1n), BLB.nkb(K, N, {KB}n, {{==}}, hN, hK8), Order.add_right(VD.s_rng(3n, N), VB.pw({P27}n), 1n, hs3))
  +hl = FD.logic__subst(Nat, z => {{Nat.is_le(z, Nat.add(VB.pw({P27}n), 1n)) == True{{}} : Bool}}, U32.to_nat(CO.NK(K)), List.length(&2, U32, EXP.ENC(EXP.MB{{dw, T, K, N, {KB}n, {KY}n}})),
    Equal.sym(Nat, List.length(&2, U32, EXP.ENC(EXP.MB{{dw, T, K, N, {KB}n, {KY}n}})), U32.to_nat(CO.NK(K)), EXP.eL(dw, T, K, N, {KB}n, {KY}n, hok)), hnk)
  (pbv2(dw, T, K), (hok, hl))

def pbb3(-w: O.Bits, +T: {TR}, +dw: Nat, +K: U32, +eo: {{w == {OBT} : O.Bits}}, +f: PBF3(dw, T, K)) -> PBR(w):
  (+fv, +f1) = f
  (+fo, +fl) = f1
  (EXP.MB{{dw, T, K, U32.to_nat(K), {KB}n, {KY}n}}, (eo, (fv, (fo, fl))))

def pbb2(-w: O.Bits, +T: {TR}, +dw: Nat, +K: U32, +eo: {{w == {OBT} : O.Bits}}, +pf: {prem[0]}, +hdw: {{Nat.is_lt(dw, {Kd}n) == True{{}} : Bool}},
    +hK8: {prem[2]}, +hKY: {prem[3]}, +hroom: {prem[4]}, +hbz: {prem[5]}, +wf: BO.wfb({OBT})) -> PBR(w):
  pbb3(w, T, dw, K, eo, pbf(T, dw, K, pf, hdw, hK8, hKY, hroom, hbz, wf))

# a progressive bit list the root law represents (wfb), with its premise: its record
def pbb(-w: O.Bits, +wf: BO.wfb(w), +hs: SDPB(w, {Kd}n)) -> PBR(w):
  (+T, +s1) = hs
  (+dw, +s2) = s1
  (+K, +s3) = s2
  (+eo, +s4) = s3
  (+pf, +s5) = s4
  (+hdw, +s6) = s5
  (+hK8, +s7) = s6
  (+hKY, +s8) = s7
  (+hroom, +hbz) = s8
  pbb2(w, T, dw, K, eo, pf, hdw, hK8, hKY, hroom, hbz, FD.logic__subst(O.Bits, z => BO.wfb(z), w, {OBT}, eo, wf))
'''


SUPPORT_OUT['e2e_encp.bend'] = encp_text()


# ---- (i) of the progressive containers: the record from its fields' records (e2e_encr lists, e2e_encp bit lists) ----
# PROGS[X] = the fields in order: ('u8',) a uint8 (rep's U32 witness), ('l', tag) a List[uint16, N] (ER.lb_tag),
# ('pb',) a progressive bit list (EP.pbb). Each record's premise is its encode law's (BL.sdk / EP.SDPB).
PROGS = {'Gp4B0CA2906A': [('pb',)], 'Gp66304057C3': [('u8',), ('l', 'l123'), ('pb',)]}


def encp_kd():
    return int(re.search(r'Nat\.is_lt\(dw, (\d+)n\)', _okt(_obj('big_encx_pbits.bend'))).group(1))


def prog_q(X, D):
    """e2e_encq's record builder of X: rq_X(o, rep, hs) -> RQ_X(o) (defs text, imports)."""
    ci = _obj(f'big_encx_{X}_iface.bend')
    okt = _okt(ci)
    names = re.findall(r'\+(\w+): ', re.search(r'^def OKT\((.*?)\) -> Bool', ci, re.M).group(1))
    fs = PROGS[X]
    assert len(names) == len(fs), (X, names)
    ren = {nm: (f'x{k}' if fs[k][0] == 'u8' else f'm{k}') for k, nm in enumerate(names)}
    for a, b in ren.items():
        okt = re.sub(rf'\b{a}\b', b, okt)
    aliases = sorted(set(re.findall(r'\b(EX_\w+|uint\d+_e|LY)\.', okt + _okt(ci, 'OKT'))) | set(re.findall(r'\b(EX_\w+)\.', re.search(r'^def VALC.*$', ci, re.M).group(0))))
    imps = []
    for al in aliases:
        p = re.search(rf'^import (\S+) as {al}$', ci, re.M).group(1)
        imps.append(f'import {p.replace("../../types/", "../types/") if p.startswith("../../types/") else "../proofs/obj/" + p[2:]} as {al}')
    MOD = lambda k: re.search(r'm_f_\w+: (EX_\w+)\.', re.search(r'^def OKT\((.*?)\) -> Bool', ci, re.M).group(1)[0:]).group(1)  # noqa: E731,F841
    fmods = dict(zip(names, re.findall(r'\+\w+: (EX_\w+\.\w+|U32)', re.search(r'^def OKT\((.*?)\) -> Bool', ci, re.M).group(1))))
    PJ = lambda k: f'RT.pj_{X}_{k}(o)'  # noqa: E731
    us = [k for k, f in enumerate(fs) if f[0] == 'u8']
    sig = [f'+rep: RT.rep_{X}(o, Spec.{X}())']
    for k, f in enumerate(fs):
        if f[0] == 'l':
            sig.append(f'+hs{k}: BL.sdk({PJ(k)}, {encr_k(f[1])}n)')
        elif f[0] == 'pb':
            sig.append(f'+hs{k}: EP.SDPB({PJ(k)}, {encp_kd()}n)')
    # the object: its fields replaced by their records' objects; the view item by item; OK conjunct by conjunct
    MW = f'CI_{X}.MW{{{", ".join(ren[n] for n in names)}}}'
    cur = [f'x{k}' if f[0] == 'u8' else PJ(k) for k, f in enumerate(fs)]
    eqn = 'eo'
    for k, f in enumerate(fs):
        if f[0] == 'u8':
            continue
        mod = fmods[names[k]].split('.')[0]
        T = 'O.Bits' if f[0] == 'pb' else 'O.Words'
        nxt = list(cur)
        nxt[k] = f'{mod}.TH(m{k})'
        mot = list(cur)
        mot[k] = 'z'
        eqn = (f'Equal.trans({D}, o, {D}{{{", ".join(cur)}}}, {D}{{{", ".join(nxt)}}},\n    {eqn},\n    '
               f'Equal.cong({T}, {D}, z => {D}{{{", ".join(mot)}}}, {PJ(k)}, {mod}.TH(m{k}), e{k}))')
        cur = nxt
    UI = lambda v: f'S.UnsignedValue{{P.UInt{{{v}, 0, 0, 0, 0, 0, 0, 0}}}}'  # noqa: E731
    lhs, rfull, eqs = [], [], []
    for k, f in enumerate(fs):
        mod = fmods[names[k]].split('.')[0] if f[0] != 'u8' else None
        if f[0] == 'u8':
            lhs.append(UI(f'x{k}'))
            rfull.append(UI(f'U32.and(x{k}, 255)'))
            eqs.append((UI('_'), f'Equal.sym(U32, U32.and(x{k}, 255), x{k}, VBB.ea(x{k}, h{k}))'))
        elif f[0] == 'l':
            lhs.append(f'PBF.vview2({mod}.TH(m{k}))')
            rfull.append(f'{mod}.VAL(m{k})')
            eqs.append(('_', f'v{k}'))
        else:
            lhs.append(f'S.BitsValue{{BO.bview({mod}.TH(m{k}))}}')
            rfull.append(f'{mod}.VAL(m{k})')
            eqs.append(('_', f'v{k}'))

    def seq(it):
        out = 'S.EmptyItems{}'
        for x in reversed(it):
            out = f'S.Items{{{x}, {out}}}'
        return f'S.Sequence{{{out}}}'
    steps = []
    for p in range(len(fs)):
        it = [lhs[q] if q < p else (eqs[q][0] if q == p else rfull[q]) for q in range(len(fs))]
        steps.append(f'  %{eqs[p][1]} : {{RT.v_{X}(CI_{X}.TH({MW})) == {seq(it)} : S.Value}}')
    # the total bound: closed field bounds, then the one bit list's (bnd)
    lens = {}
    for k, f in enumerate(fs):
        mod = fmods[names[k]].split('.')[0] if f[0] != 'u8' else None
        if f[0] == 'l':
            M2 = 2 * int(re.search(r'hk: \{Nat\.is_le\(c, (\d+)n\)', _obj(ENCR_LISTS[f[1]][1])).group(1))
            lens[f'LY.LN({mod}.ENC(m{k}))'] = (M2, f'l{k}')
        elif f[0] == 'pb':
            lens[f'LY.LN({mod}.ENC(m{k}))'] = (None, f'l{k}')
    bm = re.search(r'Nat\.is_le\((Nat\.add\(.*\)), A\.quad\(VB\.pw\((\d+)n\)\)\)', okt)
    SUM, KQ = bm.group(1), int(bm.group(2))
    SUM = SUM[:[i for i in range(len(SUM)) if SUM[:i + 1].count('(') == SUM[:i + 1].count(')') and SUM[:i + 1].count('(') > 0][0] + 1]
    a, b = [x.strip() for x in _split(SUM[len('Nat.add('):-1])]
    P27 = KQ - 1

    def closed(e):
        e = e.strip()
        if e.startswith('Nat.add('):
            x, y = [z.strip() for z in _split(e[len('Nat.add('):-1])]
            vx, px, sx = closed(x)
            vy, py, sy = closed(y)
            return vx + vy, f'ER.addle({x}, {y}, {sx}, {sy}, {px}, {py})', f'Nat.add({sx}, {sy})'
        if re.fullmatch(r'\d+n', e):
            return int(e[:-1]), f'Order.reflexive({e})', e
        v, p = lens[e]
        assert v is not None, (X, e)
        return v, p, f'{v}n'
    assert lens[b][0] is None, (X, 'the bit list is the sum\'s last term')
    va, pa, sa = closed(a)
    hc = (f'FD.nat__le_trans(Nat.add({va}n, 1n), VB.pw(9n), VB.pw({P27}n), {{==}}, VBG.pw_mono(9n, {P27}n, {{==}}))')
    BLEAF = f'Nat.is_le({SUM}, A.quad(VB.pw({KQ}n)))'
    BPROOF = (f'FD.nat__le_trans({SUM}, Nat.add({va}n, {b}), A.quad(VB.pw({KQ}n)), Order.add_right({a}, {va}n, {b}, FD.nat__le_trans({a}, {sa}, {va}n, {pa}, {{==}})),\n'
              f'    EP.bnd({va}n, {b}, VB.pw({P27}n), {lens[b][1]}, {hc}))')
    hc1 = (f'FD.nat__le_trans(Nat.add({va + 1}n, 1n), VB.pw(9n), VB.pw({P27}n), {{==}}, VBG.pw_mono(9n, {P27}n, {{==}}))')
    BPROOF1 = (f'FD.nat__le_trans(Nat.add(1n+{a}, {b}), Nat.add({va + 1}n, {b}), A.quad(VB.pw({KQ}n)), Order.add_right(1n+{a}, {va + 1}n, {b}, FD.nat__le_trans({a}, {sa}, {va}n, {pa}, {{==}})),\n'
               f'    EP.bnd({va + 1}n, {b}, VB.pw({P27}n), {lens[b][1]}, {hc1}))')
    FARGS = ', '.join(ren[n] for n in names)
    leaf = {BLEAF: 'hb'}
    for k, f in enumerate(fs):
        mod = fmods[names[k]].split('.')[0] if f[0] != 'u8' else None
        if f[0] == 'u8':
            leaf[f'uint8_e.u8_valid(x{k})'] = f'h8_{k}'
        else:
            leaf[f'{mod}.OK(m{k})'] = f'o{k}'
    HOK = _andproof(okt, leaf)
    # the fields' records
    unp, cps, unpr = [], [], []
    for k, f in enumerate(fs):
        if f[0] == 'u8':
            unp.append(f'''  +h8_{k} = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(x{k}), U32.to_nat(255)), U32.is_le(x{k}, 255),
    Equal.sym(Bool, U32.is_le(x{k}, 255), Nat.is_le(U32.to_nat(x{k}), U32.to_nat(255)), VU.le_u32(x{k}, 255)), LB.small(x{k}, h{k}))''')
            continue
        R_ = f'ER.LR_{f[1]}' if f[0] == 'l' else 'EP.PBR'
        cps.append(f'+cb{k}: {R_}({PJ(k)})')
        unpr += [f'  (+m{k}, +cb{k}a) = cb{k}', f'  (+e{k}, +cb{k}b) = cb{k}a', f'  (+v{k}, +cb{k}c) = cb{k}b', f'  (+o{k}, +l{k}) = cb{k}c']
    hparams = ''.join(f'+h{k}: {{U32.is_lt(x{k}, 256) == True{{}} : Bool}}, ' for k in us)
    xparams = ''.join(f'+x{k}: U32, ' for k in us)
    E0 = f'{D}{{{", ".join(f"x{k}" if f[0] == "u8" else PJ(k) for k, f in enumerate(fs))}}}'
    vwp = ''.join(f'+{"x" if f[0] == "u8" else "m"}{k}: {fmods[names[k]]}, ' for k, f in enumerate(fs))
    vwh = ''.join(f'+h{k}: {{U32.is_lt(x{k}, 256) == True{{}} : Bool}}, ' for k in us)
    vwv = []
    for k, f in enumerate(fs):
        if f[0] == 'u8':
            continue
        vwv.append(f'+v{k}: {{{lhs[k]} == {rfull[k]} : S.Value}}')
    vwargs = ', '.join([('x' if f[0] == 'u8' else 'm') + str(k) for k, f in enumerate(fs)] + [f'h{k}' for k in us] + [f'v{k}' for k, f in enumerate(fs) if f[0] != 'u8'])
    defs = f'''# the object's view is the record's
def vw_{X}({vwp}{vwh}{", ".join(vwv)}) -> {{RT.v_{X}(CI_{X}.TH({MW})) == CI_{X}.VAL({MW}) : S.Value}}:
''' + '\n'.join(steps) + f'''
  {{==}}

# the object's record from its fields' records
def c1_{X}(-o: {D}, {xparams}+eo: {{o == {E0} : {D}}}, {hparams}{", ".join(cps)})
    -> RQ_{X}(o):
{chr(10).join(unpr + unp)}
  +hb = {BPROOF}
  +hok = {HOK}
  +hb1 = {BPROOF1}
  +lb = FD.logic__subst(Nat, z => {{Nat.is_le(1n+z, A.quad(VB.pw({KQ}n))) == True{{}} : Bool}}, {SUM}, List.length(&2, U32, K_{X}.ENCC({FARGS})),
    Equal.sym(Nat, List.length(&2, U32, K_{X}.ENCC({FARGS})), {SUM}, CI_{X}.lenE({FARGS}, hok)), hb1)
  ({MW}, ({eqn}, (vw_{X}({vwargs}), (hok, lb))))
'''
    lbt = {}
    for k, f in enumerate(fs):
        if f[0] == 'l':
            lbt[k] = str(2 * int(re.search(r'hk: \{Nat\.is_le\(c, (\d+)n\)', _obj(ENCR_LISTS[f[1]][1])).group(1))) + 'n'
        elif f[0] == 'pb':
            lbt[k] = 'Nat.add(VB.pw(27n), 1n)'
    defs = _c1_split(X, D, defs, MW, fs, fmods, names, vwv, lbt)
    lines, src = [], 'rep'
    for i, k in enumerate(us):
        lines.append(f'  (+x{k}, +r{i}) = {src}')
        src = f'r{i}'
    n = len(fs)
    lines.append(f'  (+eo, +q0) = {src}')
    pn = {i: (f'q{i}' if i == n - 1 else f'p{i}') for i in range(n)}
    for i in range(n - 1):
        lines.append(f'  (+p{i}, +q{i + 1}) = q{i}')
    pks = [k for k, f in enumerate(fs) if f[0] != 'u8']
    src = 'hs'
    for i, k in enumerate(pks):
        lines.append(f'  +hs{k} = {src}' if i == len(pks) - 1 else f'  (+hs{k}, +hr{i}) = {src}')
        src = f'hr{i}'
    args = []
    for k, f in enumerate(fs):
        if f[0] == 'l':
            args.append(f'ER.lb_{f[1]}({PJ(k)}, {pn[k]}, hs{k})')
        elif f[0] == 'pb':
            args.append(f'EP.pbb({PJ(k)}, {pn[k]}, hs{k})')
    lines.append(f'  c1_{X}(o, {"".join(f"x{k}, " for k in us)}eo, {"".join(pn[k] + ", " for k in us)}' + ', '.join(args) + ')')
    prems = []
    for k, f in enumerate(fs):
        if f[0] == 'l':
            prems.append(f'BL.sdk({PJ(k).replace("(o)", "(v)")}, {encr_k(f[1])}n)')
        elif f[0] == 'pb':
            prems.append(f'EP.SDPB({PJ(k).replace("(o)", "(v)")}, {encp_kd()}n)')
    PREM = prems[-1]
    for q in reversed(prems[:-1]):
        PREM = f'DK.P2({q}, {PREM})'
    head = f"""# ---- {X} ----
def PREM_{X}(v: {D}) -> Data: {PREM}

def RQ_{X}(o: {D}) -> Data:
  DK.Ex(CI_{X}.MW, m => DK.P2({{o == CI_{X}.TH(m) : {D}}}, DK.P2({{RT.v_{X}(CI_{X}.TH(m)) == CI_{X}.VAL(m) : S.Value}},
    DK.P2({{CI_{X}.OK(m) == True{{}} : Bool}}, {{Nat.is_le(1n+LY.LN(CI_{X}.ENC(m)), A.quad(VB.pw({KQ}n))) == True{{}} : Bool}}))))

"""
    rq = f"""
def rq_{X}(-o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), +hs: PREM_{X}(o)) -> RQ_{X}(o):
""" + '\n'.join(lines) + '\n'
    kmod = re.search(r'^import (\S+) as K$', ci, re.M).group(1)
    imps += [f'import ../proofs/obj/big_encx_{X}_iface.bend as CI_{X}', f'import ../proofs/obj/{kmod[2:]} as K_{X}']
    return head + defs + rq, imps


def prog_premise(X):
    fs = PROGS[X]
    parts = []
    for k, f in enumerate(fs):
        if f[0] == 'l':
            parts.append(f'hs{k}: BL.sdk(pj_{k}(o), {encr_k(f[1])}n) (field {k}\'s words below depth {encr_k(f[1])})')
        elif f[0] == 'pb':
            parts.append(f'hs{k}: EP.SDPB(pj_{k}(o), {encp_kd()}n) (field {k}\'s bit list: its words below depth {encp_kd()}, the widths at B = K, '
                         '(K >> 5) + 1 words, the bits above K zero)')
    return (f'rep: RT.rep_{X}(o, Spec.{X}()) and the storage premises, each at its field\'s encode law\'s bounds (read from the law): ' + '; '.join(parts))


for _X in PROGS:
    VENC_SHAPES[_X] = venc_mw


def _c1_split(X, D, defs, MW, fs, fmods, names, vwv, lbt):
    """Split c1_X into c1f_X (the record's facts from its fields' explicit records: view, OK, 1 + bytes bound),
    c1p_X (package) and c1_X (from the fields' record bundles), so another record can take c1f_X's facts."""
    i = defs.index('\ndef c1_')
    head, c1 = defs[:i], defs[i:]
    fi = c1.index(f'\n  ({MW}, (')
    fin = c1[fi + 1:].rstrip()
    lines = c1[:fi].split('\n')
    sig = '\n'.join(lines[1:3])
    body = [ln for ln in '\n'.join(lines[3:]).split('\n')]
    unpr = [ln for ln in body if re.match(r'  \(\+[mevo]\d+, \+(cb\d+[a-c]|l\d+)\) = cb\d+[a-c]?$', ln)]
    rest = [ln for ln in body if ln not in unpr and ln.strip()] + [fin]
    m = re.match(rf'  \({re.escape(MW)}, \((.*), \(vw_{X}\((.*?)\), \(hok, lb\)\)\)\)$', fin, re.S)
    eqn, vwargs = m.group(1), m.group(2)
    us = [k for k, f in enumerate(fs) if f[0] == 'u8']
    vs = [k for k, f in enumerate(fs) if f[0] != 'u8']
    xp = ''.join(f'+x{k}: U32, ' for k in us)
    mp = ''.join(f'+m{k}: {fmods[names[k]]}, ' for k in vs)
    hp = ''.join(f'+h{k}: {{U32.is_lt(x{k}, 256) == True{{}} : Bool}}, ' for k in us)
    mod = {k: fmods[names[k]].split('.')[0] for k in vs}
    vp = ''.join(v + ', ' for v in vwv)
    op = ''.join(f'+o{k}: {{{mod[k]}.OK(m{k}) == True{{}} : Bool}}, ' for k in vs)
    lp = ', '.join(f'+l{k}: {{Nat.is_le(LY.LN({mod[k]}.ENC(m{k})), {lbt[k]}) == True{{}} : Bool}}' for k in vs)
    fa = ', '.join([f'x{k}' for k in us] + [f'm{k}' for k in vs])
    CF = f'CF_{X}({fa})'
    cfp = ''.join(f'+x{k}: U32, ' for k in us) + ''.join(f'+m{k}: {fmods[names[k]]}, ' for k in vs)
    cfdef = f"""# the record's facts: its view, valid, 1 + its bytes within the bound
def CF_{X}({cfp[:-2]}) -> Data:
  DK.P2({{RT.v_{X}(CI_{X}.TH({MW})) == CI_{X}.VAL({MW}) : S.Value}}, DK.P2({{CI_{X}.OK({MW}) == True{{}} : Bool}}, {{Nat.is_le(1n+LY.LN(CI_{X}.ENC({MW})), A.quad(VB.pw(28n))) == True{{}} : Bool}}))

def c1f_{X}({xp}{mp}{hp}{vp}{op}{lp}) -> {CF}:
""" + '\n'.join(rest[:-1]) + f"""
  (vw_{X}({vwargs}), (hok, lb))

def c1p_{X}(-o: {D}, {cfp}+eq: {{o == CI_{X}.TH({MW}) : {D}}}, +f: {CF}) -> RQ_{X}(o):
  (+fv, +f1) = f
  (+fo, +fl) = f1
  ({MW}, (eq, (fv, (fo, fl))))
"""
    cargs = ', '.join([f'x{k}' for k in us] + [f'm{k}' for k in vs] + [f'h{k}' for k in us] + [f'v{k}' for k in vs] + [f'o{k}' for k in vs] + [f'l{k}' for k in vs])
    c1n = f"""
# the object's record from its fields' records
{sig.strip()}
""" + '\n'.join(unpr) + f"""
  c1p_{X}(o, {fa}, {eqn}, c1f_{X}({cargs}))
"""
    return head.rstrip('\n').rsplit('\n# the object\'s record from its fields\' records', 1)[0] + '\n\n' + cfdef + c1n


def encq_text():
    L, imps = [], []
    for X in PROGS:
        D = f'T.{X}'
        t, im = prog_q(X, D)
        L.append(t)
        imps += im
    head = ['import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P', 'import ../types/generic_obj.bend as T',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/vbuf.bend as VB',
            'import ../proofs/obj/dk.bend as DK', 'import ../proofs/obj/generic_specs.bend as Spec',
            'import ../proofs/obj/root_gtypes2.bend as RT', 'import ../proofs/obj/vu32.bend as VU', 'import ../proofs/obj/len_bridge.bend as LB',
            'import ../proofs/obj/vbitb.bend as VBB', 'import ../proofs/obj/vbig.bend as VBG', 'import ../proofs/obj/packed_bytes.bend as PBF',
            'import ../proofs/obj/bitlist_obj.bend as BO', 'import ../proofs/nat_order.bend as Order', 'import ./e2e_blist.bend as BL',
            'import ./e2e_encr.bend as ER', 'import ./e2e_encp.bend as EP']
    return '\n'.join(dict.fromkeys(head + imps)) + '''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# The progressive containers' encode records from the root law's representation (rq_X): the object is
# TH(m), its view VAL(m), m valid, 1 + its bytes within the bound (what a union's arm record takes).

''' + '\n'.join(L)


SUPPORT_OUT['e2e_encq.bend'] = encq_text()


def mwp_prog2(R, X, D):
    defs = f'''def vq(-o: {D}, +c: EQ.RQ_{X}(o)) -> {{Some{{E.obytes(Pair.snd({D}, B.Buf, {R}_e.{X}_encode(o)))}} == API.serialize(Spec.{X}(), RT.v_{X}(o)) : Maybe<&2, +List<U32>>}}:
  (+m, +c1) = c
  (+eo, +c2) = c1
  (+ev, +c3) = c2
  (+hok, +lb) = c3
  via(o, m, eo, ev, hok)
'''
    return defs, f'  vq(o, EQ.rq_{X}(o, rep, hs))', ['import ../proofs/obj/root_gtypes2.bend as RT', 'import ./e2e_encq.bend as EQ'], f'+rep: RT.rep_{X}(o, Spec.{X}()), +hs: EQ.PREM_{X}(o)'


def prog_premise2(X):
    return (f'rep: RT.rep_{X}(o, Spec.{X}()) and hs: EQ.PREM_{X}(o), its storage fields\' premises at their encode laws\' bounds (read from the laws): '
            + prog_premise(X).split(': ', 2)[-1])


for _X in PROGS:
    MWP[_X] = mwp_prog2
    VENC_PREMISE[_X] = prog_premise2(_X)


# PROGS2[X]: the list-field containers' fields: ('u8',), ('l', tag), ('pb',), ('pu8',), ('pu64',), ('rl', tag), ('vl', tag)
PROGS2 = {
    'Gc221EC01D83': [('pu8',), ('pu64',), ('rl', 'pl_Gc4ED9619F50'), ('vl', 'pl_pl_Gc465214E502')],
    'Gp8A7851175B': [('u8',), ('l', 'l123'), ('pb',), ('pu64',), ('rl', 'pl_Gc4ED9619F50'), ('vl', 'pl_pl_Gc465214E502'), ('rl', 'l10_GpF350A3C486'), ('vl', 'pl_Gp66304057C3')],
}


def prog_q2(X, D):
    """e2e_encq2's record builder of X (list fields, the KP bound): rq_X(o, rep, hs) -> RQ_X(o) (defs text, imports)."""
    ci = _obj(f'big_encx_{X}_iface.bend')
    okt = _okt(ci)
    names = re.findall(r'\+(\w+): ', re.search(r'^def OKT\((.*?)\) -> Bool', ci, re.M).group(1))
    fs = PROGS2[X]
    assert len(names) == len(fs), (X, names)
    ren = {nm: (f'x{k}' if fs[k][0] == 'u8' else f'm{k}') for k, nm in enumerate(names)}
    for a, b in ren.items():
        okt = re.sub(rf'\b{a}\b', b, okt)
    aliases = sorted(set(re.findall(r'\b(EX_\w+|uint\d+_e|LY)\.', okt + _okt(ci, 'OKT'))) | set(re.findall(r'\b(EX_\w+)\.', re.search(r'^def VALC.*$', ci, re.M).group(0))))
    imps = []
    for al in aliases:
        p = re.search(rf'^import (\S+) as {al}$', ci, re.M).group(1)
        imps.append(f'import {p.replace("../../types/", "../types/") if p.startswith("../../types/") else "../proofs/obj/" + p[2:]} as {al}')
    fmods = dict(zip(names, re.findall(r'\+\w+: (EX_\w+\.\w+|U32)', re.search(r'^def OKT\((.*?)\) -> Bool', ci, re.M).group(1))))
    PJ = lambda k: f'RT.pj_{X}_{k}(o)'  # noqa: E731
    us = [k for k, f in enumerate(fs) if f[0] == 'u8']
    MW = f'CI_{X}.MW{{{", ".join(ren[n] for n in names)}}}'
    mod = {k: fmods[names[k]].split('.')[0] for k, f in enumerate(fs) if f[0] != 'u8'}
    # the object's fields replaced by their records' objects
    cur = [f'x{k}' if f[0] == 'u8' else PJ(k) for k, f in enumerate(fs)]
    eqn = 'eo'
    TYP = {'l': 'O.Words', 'pu8': 'O.Words', 'pu64': 'O.Words', 'pb': 'O.Bits'}
    for k, f in enumerate(fs):
        if f[0] == 'u8':
            continue
        T = TYP.get(f[0]) or re.search(rf'^def TH\(m: MW\) -> (\S+):', _obj(re.search(rf'^import \./(\S+) as {mod[k]}$', ci, re.M).group(1)), re.M).group(1)
        if '.' in T and T.split('.')[0].endswith('_d'):
            al = T.split('.')[0]
            imps.append(f'import ../types/{al[:-2]}_def_generated.bend as {al}')
        nxt = list(cur)
        nxt[k] = f'{mod[k]}.TH(m{k})'
        mot = list(cur)
        mot[k] = 'z'
        eqn = (f'Equal.trans({D}, o, {D}{{{", ".join(cur)}}}, {D}{{{", ".join(nxt)}}},\n    {eqn},\n    '
               f'Equal.cong({T}, {D}, z => {D}{{{", ".join(mot)}}}, {PJ(k)}, {mod[k]}.TH(m{k}), e{k}))')
        cur = nxt
    UI = lambda v: f'S.UnsignedValue{{P.UInt{{{v}, 0, 0, 0, 0, 0, 0, 0}}}}'  # noqa: E731
    VIEW = {'l': lambda m: f'PBF.vview2({m})', 'pb': lambda m: f'S.BitsValue{{BO.bview({m})}}', 'pu8': lambda m: f'PBF.vview1({m})', 'pu64': lambda m: f'UL.uview({m})'}
    lhs, rfull, eqs = [], [], []
    for k, f in enumerate(fs):
        if f[0] == 'u8':
            lhs.append(UI(f'x{k}'))
            rfull.append(UI(f'U32.and(x{k}, 255)'))
            eqs.append((UI('_'), f'Equal.sym(U32, U32.and(x{k}, 255), x{k}, VBB.ea(x{k}, h{k}))'))
            continue
        th = f'{mod[k]}.TH(m{k})'
        lhs.append(VIEW[f[0]](th) if f[0] in VIEW else f'RT.xv_{f[1]}({th})')
        rfull.append(f'{mod[k]}.VAL(m{k})')
        eqs.append(('_', f'v{k}'))

    def seq(it):
        out = 'S.EmptyItems{}'
        for x in reversed(it):
            out = f'S.Items{{{x}, {out}}}'
        return f'S.Sequence{{{out}}}'
    steps = []
    for p in range(len(fs)):
        it = [lhs[q] if q < p else (eqs[q][0] if q == p else rfull[q]) for q in range(len(fs))]
        steps.append(f'  %{eqs[p][1]} : {{RT.v_{X}(CI_{X}.TH({MW})) == {seq(it)} : S.Value}}')
    # the total bound: a closed start c0, closed field bounds (acc), and unbounded ones of P + 1 (acu), then fin
    bm = re.search(r'Nat\.is_le\((Nat\.add\(.*\)), A\.quad\(VB\.pw\((\d+)n\)\)\)', okt)
    SUM, KQ = bm.group(1), int(bm.group(2))
    SUM = SUM[:[i for i in range(len(SUM)) if SUM[:i + 1].count('(') == SUM[:i + 1].count(')') and SUM[:i + 1].count('(') > 0][0] + 1]
    assert KQ == 28
    terms = []
    e = SUM
    while e.startswith('Nat.add('):
        a, b = [z.strip() for z in _split(e[len('Nat.add('):-1])]
        terms.append(b)
        e = a
    c0 = int(e[:-1])
    terms.reverse()
    tb = {}
    for k, f in enumerate(fs):
        if f[0] == 'u8':
            continue
        key = f'LY.LN({mod[k]}.ENC(m{k}))'
        if f[0] == 'l':
            tb[key] = (2 * int(re.search(r'hk: \{Nat\.is_le\(c, (\d+)n\)', _obj(ENCR_LISTS[f[1]][1])).group(1)), f'l{k}')
        elif f[0] == 'rl' and ENCL_RL[f[1]][7] is not None:
            tb[key] = (ENCL_RL[f[1]][7], f'l{k}')
        else:
            tb[key] = (None, f'l{k}')
    P = 'VB.pw(27n)'

    def chain(start, name):
        out = []
        c, cv, kk = f'{start}n', start, 0
        prev = f'{start}n'
        out.append(f'  +{name}0 = EL.acz({start}n, {P})')
        for i, t in enumerate(terms):
            B, pr = tb[t]
            if B is None:
                out.append(f'  +{name}{i + 1} = EL.acu({prev}, {t}, {c}, {kk}n, {P}, {name}{i}, {pr})')
                c, cv, kk = f'Nat.add({c}, 1n)', cv + 1, kk + 1
            else:
                out.append(f'  +{name}{i + 1} = EL.acc({prev}, {t}, {c}, {B}n, {kk}n, {P}, {name}{i}, {pr})')
                c, cv = f'Nat.add({c}, {B}n)', cv + B
            prev = f'Nat.add({prev}, {t})'
        assert kk <= 7 and cv + 1 <= 512, (X, kk, cv)
        out.append(f'  +{name} = EL.fin({prev}, {c}, {kk}n, {P}, {name}{len(terms)}, FD.nat__le_trans({c}, VB.pw(9n), {P}, {{==}}, VBG.pw_mono(9n, 27n, {{==}})), {{==}})')
        return out
    BLEAF = f'Nat.is_le({SUM}, A.quad(VB.pw({KQ}n)))'
    leaf = {BLEAF: 'hb'}
    for k, f in enumerate(fs):
        if f[0] == 'u8':
            leaf[f'uint8_e.u8_valid(x{k})'] = f'h8_{k}'
        else:
            leaf[f'{mod[k]}.OK(m{k})'] = f'o{k}'
    HOK = _andproof(okt, leaf)
    FARGS = ', '.join(ren[n] for n in names)
    SUM1 = SUM.replace(f'Nat.add({c0}n,', f'Nat.add({c0 + 1}n,', 1)
    unp, cps, unpr = [], [], []
    BUND = {'l': lambda f: f'ER.LR_{f[1]}', 'pb': lambda f: 'EP.PBR', 'pu8': lambda f: 'EL.LR_pu8', 'pu64': lambda f: 'EL.LR_pu64',
            'rl': lambda f: f'EL.LRR_{f[1]}', 'vl': lambda f: f'EL.LRV_{f[1]}'}
    for k, f in enumerate(fs):
        if f[0] == 'u8':
            unp.append(f'''  +h8_{k} = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(x{k}), U32.to_nat(255)), U32.is_le(x{k}, 255),
    Equal.sym(Bool, U32.is_le(x{k}, 255), Nat.is_le(U32.to_nat(x{k}), U32.to_nat(255)), VU.le_u32(x{k}, 255)), LB.small(x{k}, h{k}))''')
            continue
        cps.append(f'+cb{k}: {BUND[f[0]](f)}({PJ(k)})')
        unpr += [f'  (+m{k}, +cb{k}a) = cb{k}', f'  (+e{k}, +cb{k}b) = cb{k}a', f'  (+v{k}, +cb{k}c) = cb{k}b', f'  (+o{k}, +l{k}) = cb{k}c']
    hparams = ''.join(f'+h{k}: {{U32.is_lt(x{k}, 256) == True{{}} : Bool}}, ' for k in us)
    xparams = ''.join(f'+x{k}: U32, ' for k in us)
    E0 = f'{D}{{{", ".join(f"x{k}" if f[0] == "u8" else PJ(k) for k, f in enumerate(fs))}}}'
    vwp = ''.join(f'+{"x" if f[0] == "u8" else "m"}{k}: {fmods[names[k]]}, ' for k, f in enumerate(fs))
    vwh = ''.join(f'+h{k}: {{U32.is_lt(x{k}, 256) == True{{}} : Bool}}, ' for k in us)
    vwv = [f'+v{k}: {{{lhs[k]} == {rfull[k]} : S.Value}}' for k, f in enumerate(fs) if f[0] != 'u8']
    vwargs = ', '.join([('x' if f[0] == 'u8' else 'm') + str(k) for k, f in enumerate(fs)] + [f'h{k}' for k in us] + [f'v{k}' for k, f in enumerate(fs) if f[0] != 'u8'])
    defs = f'''# the object's view is the record's
def vw_{X}({vwp}{vwh}{", ".join(vwv)}) -> {{RT.v_{X}(CI_{X}.TH({MW})) == CI_{X}.VAL({MW}) : S.Value}}:
''' + '\n'.join(steps) + f'''
  {{==}}

# the object's record from its fields' records
def c1_{X}(-o: {D}, {xparams}+eo: {{o == {E0} : {D}}}, {hparams}{", ".join(cps)})
    -> RQ_{X}(o):
{chr(10).join(unpr + unp)}
{chr(10).join(chain(c0, 'hb'))}
  +hok = {HOK}
{chr(10).join(chain(c0 + 1, 'hc'))}
  +lb = FD.logic__subst(Nat, z => {{Nat.is_le(1n+z, A.quad(VB.pw({KQ}n))) == True{{}} : Bool}}, {SUM}, List.length(&2, U32, K_{X}.ENCC({FARGS})),
    Equal.sym(Nat, List.length(&2, U32, K_{X}.ENCC({FARGS})), {SUM}, CI_{X}.lenE({FARGS}, hok)), hc)
  ({MW}, ({eqn}, (vw_{X}({vwargs}), (hok, lb))))
'''
    lbt = {}
    for k, f in enumerate(fs):
        if f[0] == 'u8':
            continue
        B = tb[f'LY.LN({mod[k]}.ENC(m{k}))'][0]
        lbt[k] = 'Nat.add(VB.pw(27n), 1n)' if f[0] == 'pb' else ('EL.P1()' if B is None else f'{B}n')
    defs = _c1_split(X, D, defs, MW, fs, fmods, names, vwv, lbt)
    # rq: the rep's parts, the premises' parts, the fields' records
    lines, src = [], 'rep'
    for i, k in enumerate(us):
        lines.append(f'  (+x{k}, +r{i}) = {src}')
        src = f'r{i}'
    n = len(fs)
    lines.append(f'  (+eo, +q0) = {src}')
    pn = {i: (f'q{i}' if i == n - 1 else f'p{i}') for i in range(n)}
    for i in range(n - 1):
        lines.append(f'  (+p{i}, +q{i + 1}) = q{i}')
    pks = [k for k, f in enumerate(fs) if f[0] != 'u8']
    src = 'hs'
    HS = {}
    for i, k in enumerate(pks):
        if i == len(pks) - 1:
            HS[k] = src
        else:
            lines.append(f'  (+hs{k}, +hr{i}) = {src}')
            HS[k] = f'hs{k}'
        src = f'hr{i}'
    args = []
    for k, f in enumerate(fs):
        if f[0] == 'l':
            args.append(f'ER.lb_{f[1]}({PJ(k)}, {pn[k]}, {HS[k]})')
        elif f[0] == 'pb':
            args.append(f'EP.pbb({PJ(k)}, {pn[k]}, {HS[k]})')
        elif f[0] == 'pu8':
            args.append(f'EL.lb_pu8({PJ(k)}, {pn[k]}, {HS[k]})')
        elif f[0] == 'pu64':
            args.append(f'EL.lb_pu64({PJ(k)}, {pn[k]}, {HS[k]})')
        elif f[0] == 'rl':
            sch = FSCH(X, k)
            lim = '' if ENCL_RL[f[1]][7] is None else '{==}, '
            args.append(f'EL.rb_{f[1]}({PJ(k)}, {sch}, {pn[k]}, {lim}{HS[k]})')
        elif f[0] == 'vl':
            sch = FSCH(X, k)
            args.append(f'EL.rv_{f[1]}({PJ(k)}, {sch}, {pn[k]}, {HS[k]}, {{==}})')
    lines.append(f'  c1_{X}(o, {"".join(f"x{k}, " for k in us)}eo, {"".join(pn[k] + ", " for k in us)}' + ', '.join(args) + ')')
    PRM = {'l': lambda f, pj: f'BL.sdk({pj}, {encr_k(f[1])}n)', 'pb': lambda f, pj: f'EP.SDPB({pj}, {encp_kd()}n)', 'pu8': lambda f, pj: f'EL.PW1({pj})',
           'pu64': lambda f, pj: f'EL.PW1({pj})', 'rl': lambda f, pj: f'EL.PRL_{f[1]}({pj})', 'vl': lambda f, pj: f'EL.PRV_{f[1]}({pj})'}
    prems = [PRM[f[0]](f, PJ(k).replace('(o)', '(v)')) for k, f in enumerate(fs) if f[0] != 'u8']
    PREM = prems[-1]
    for q in reversed(prems[:-1]):
        PREM = f'DK.P2({q}, {PREM})'
    head = f"""# ---- {X} ----
def PREM_{X}(v: {D}) -> Data: {PREM}

def RQ_{X}(o: {D}) -> Data:
  DK.Ex(CI_{X}.MW, m => DK.P2({{o == CI_{X}.TH(m) : {D}}}, DK.P2({{RT.v_{X}(CI_{X}.TH(m)) == CI_{X}.VAL(m) : S.Value}},
    DK.P2({{CI_{X}.OK(m) == True{{}} : Bool}}, {{Nat.is_le(1n+LY.LN(CI_{X}.ENC(m)), A.quad(VB.pw({KQ}n))) == True{{}} : Bool}}))))

"""
    rq = f"""
def rq_{X}(-o: {D}, +rep: RT.rep_{X}(o, Spec.{X}()), +hs: PREM_{X}(o)) -> RQ_{X}(o):
""" + '\n'.join(lines) + '\n'
    kmod = re.search(r'^import (\S+) as K$', ci, re.M).group(1)
    imps += [f'import ../proofs/obj/big_encx_{X}_iface.bend as CI_{X}', f'import ../proofs/obj/{kmod[2:]} as K_{X}']
    return head + defs + rq, imps


def FSCH(X, k):
    """The schema the rep of X passes its field k (the rep's own expression, at Spec.X())."""
    rep_src = _obj('root_gtypes2.bend')
    line = re.search(rf'^def rep_{X}\(o: .*\n(.*\n)?', rep_src, re.M).group(0)
    mm = re.search(rf'rep_\w+\(pj_{X}_{k}\(o\), ', line)
    j = mm.end()
    depth, e = 0, j
    while True:
        ch = line[e]
        if ch == '(':
            depth += 1
        elif ch == ')':
            if depth == 0:
                break
            depth -= 1
        elif ch == ',' and depth == 0:
            break
        e += 1
    return line[j:e].replace('(s)', f'(Spec.{X}())')


def encq2_text():
    L, imps = [], []
    for X in PROGS2:
        D = f'T.{X}'
        t, im = prog_q2(X, D)
        L.append(t)
        imps += im
    head = ['import Base', 'import ../src/obj.bend as O', 'import ../types/schema.bend as S', 'import ../types/primitive.bend as P', 'import ../types/generic_obj.bend as T',
            'import ../proofs/compact/found.bend as FD', 'import ../proofs/compact/arith.bend as A', 'import ../proofs/obj/vbuf.bend as VB',
            'import ../proofs/obj/dk.bend as DK', 'import ../proofs/obj/generic_specs.bend as Spec', 'import ../proofs/obj/schema_shapes.bend as SH',
            'import ../proofs/obj/root_gtypes2.bend as RT', 'import ../proofs/obj/vu32.bend as VU', 'import ../proofs/obj/len_bridge.bend as LB',
            'import ../proofs/obj/vbitb.bend as VBB', 'import ../proofs/obj/vbig.bend as VBG', 'import ../proofs/obj/packed_bytes.bend as PBF',
            'import ../proofs/obj/bitlist_obj.bend as BO', 'import ../proofs/obj/ulist_obj.bend as UL', 'import ../proofs/nat_order.bend as Order',
            'import ./e2e_blist.bend as BL', 'import ./e2e_encr.bend as ER', 'import ./e2e_encp.bend as EP', 'import ./e2e_encl.bend as EL']
    return '\n'.join(dict.fromkeys(head + imps)) + '''

# GENERATED by codegen/e2e_bridge.py (entries: codegen/e2e_var_c.py). Do not edit.
# The progressive containers with list fields: their encode records from the root law's representation
# (rq_X), as e2e_encq's, the byte bound through e2e_encl's KP chain (each list field within P1 = 2^27 + 1).

''' + '\n'.join(L)


SUPPORT_OUT['e2e_encq2.bend'] = encq2_text()


def mwp_prog3(R, X, D):
    defs, call, imps, sig = mwp_prog2(R, X, D)
    return defs, call, [i.replace('./e2e_encq.bend as EQ', './e2e_encq2.bend as EQ') for i in imps], sig


def prog_premise3(X):
    return (f'rep: RT.rep_{X}(o, Spec.{X}()) and hs: EQ.PREM_{X}(o), the encode records\' own bounds as premises, each a decoded-object gap '
            '(the root law\'s invariant gives depth below 32 and no size bound; decoded fields reach NMAX; dropped when the encoder window widens '
            '(codec-var), then regenerated with the budgets read from the widened law): each list field\'s storage at its encode law\'s depth bound '
            '(byte storage and record trees dw < 28, the variable-element mirror trees dw < 31), each unbounded list field\'s encoding within '
            'EL.P1 = 2^27 + 1 bytes (a per-field budget so that the fields and the fixed part fit the container law\'s 2^30), and each element\'s '
            'storage premise (words dw < 28, bit lists EP.SDPB)')


for _X in PROGS2:
    MWP[_X] = mwp_prog3
    VENC_SHAPES[_X] = venc_mw
    VENC_PREMISE[_X] = prog_premise3(_X)


# ---- (i) of a CompatibleUnion with any arms: the selected arm's record (a uint8 container's value, or a
# progressive container's record e2e_encq.rq_Arm under its premises SU(o)) as the union's record MWk ----
def mwp_union_n(R, X, D):
    vsrc = _unlight((ROOT / 'proofs/obj/root_gtypes2.bend').read_text())
    pcs = dict((int(k), b) for k, b in re.findall(rf'^def pc_{X}_(\d+)\(o: .*?\) -> Data: (.*)$', vsrc, re.M))
    ci = _obj(f'big_encx_{X}_iface.bend')
    G = lambda o: f'{{Some{{E.obytes(Pair.snd({D}, B.Buf, {R}_e.{X}_encode({o})))}} == API.serialize(Spec.{X}(), RT.v_{X}({o})) : Maybe<&2, +List<U32>>}}'  # noqa: E731
    vbody = re.search(rf'^def v_{X}\(o: .*?\n  match o:\n((?:    case .*\n)+)', vsrc, re.M).group(1)
    sels = dict((int(c), sel) for c, sel in re.findall(rf'case \w+\.{X}_c(\d+){{v}}: S\.Selected{{(\d+),', vbody))
    L, su = [], []
    for k in sorted(pcs):
        b = pcs[k]
        m = re.match(r'DK\.Ex\((\w+)\.(\w+), v =>', b)
        if m:
            C = f'T.{m.group(2)}'
            su.append(f'    case {D}_c{k}{{v}}: {{True{{}} == True{{}} : Bool}}')
            L.append(f'''def dx{k}(-o: {D}, +x: U32, +eo: {{o == {D}_c{k}{{{C}{{x}}}} : {D}}}, +hv: {{U32.is_lt(x, 256) == True{{}} : Bool}}) -> {G('o')}:
  +hok = FD.logic__subst(Bool, z => {{z == True{{}} : Bool}}, Nat.is_le(U32.to_nat(x), U32.to_nat(255)), U32.is_le(x, 255),
    Equal.sym(Bool, U32.is_le(x, 255), Nat.is_le(U32.to_nat(x), U32.to_nat(255)), VU.le_u32(x, 255)), LB.small(x, hv))
  +ev = Equal.cong(U32, S.Value, z => S.Selected{{{sels[k]}, S.Sequence{{S.Items{{S.UnsignedValue{{P.UInt{{z, 0, 0, 0, 0, 0, 0, 0}}}}, S.EmptyItems{{}}}}}}}}, x, U32.and(x, 255),
    Equal.sym(U32, U32.and(x, 255), x, VBB.ea(x, hv)))
  via(o, CI.MW{k}{{x}}, eo, ev, hok)
def dk{k}(-o: {D}, +v: {C}, +eo: {{o == {D}_c{k}{{v}} : {D}}}, +rp: RN.rp_{m.group(2)}(v)) -> {G('o')}:
  match v:
    case {C}{{+x}}: dx{k}(o, x, eo, rp)
def arm{k}(-o: {D}, +pc: RT.pc_{X}_{k}(o), +hs: SU(o)) -> {G('o')}:
  (+v, +q) = pc
  (+eo, +rp) = q
  dk{k}(o, v, eo, rp)
''')
        else:
            m2 = re.match(rf'DK\.P2\(\{{o == \w+\.{X}_c{k}\{{pju_{X}_{k}\(o\)\}} : \S+\}}, rep_(\w+)\(pju_{X}_{k}\(o\), (.*)\)\)$', b)
            A = m2.group(1)
            EA = re.search(rf'^import \./big_encx_{A}_iface\.bend as (\w+)$', ci, re.M).group(1)
            PJU = f'RT.pju_{X}_{k}(o)'
            su.append(f'    case {D}_c{k}{{v}}: EQ.PREM_{A}(v)')
            L.append(f'''def ak{k}(-o: {D}, +eo: {{o == {D}_c{k}{{{PJU}}} : {D}}}, +c: EQ.RQ_{A}({PJU})) -> {G('o')}:
  (+m, +c1) = c
  (+e, +c2) = c1
  (+v, +c3) = c2
  (+ok, +lb) = c3
  via(o, CI.MW{k}{{m}}, Equal.trans({D}, o, {D}_c{k}{{{PJU}}}, {D}_c{k}{{{EA}.TH(m)}}, eo, Equal.cong(T.{A}, {D}, z => {D}_c{k}{{z}}, {PJU}, {EA}.TH(m), e)),
    Equal.cong(S.Value, S.Value, z => S.Selected{{{sels[k]}, z}}, RT.v_{A}({EA}.TH(m)), {EA}.VAL(m), v),
    FD.logic__and_intro({EA}.OK(m), Nat.is_le(1n+List.length(&2, U32, {EA}.ENC(m)), A.quad(VB.pw(28n))), ok, lb))
def arm{k}(-o: {D}, +pc: RT.pc_{X}_{k}(o), +hs: SU(o)) -> {G('o')}:
  (+eo, +ra) = pc
  ak{k}(o, eo, EQ.rq_{A}({PJU}, ra, FD.logic__subst({D}, z => SU(z), o, {D}_c{k}{{{PJU}}}, eo, hs)))
''')
    pors = sorted(int(i) for i in re.findall(rf'^def por_{X}_(\d+)\(', vsrc, re.M))
    for i in reversed(pors):
        b = re.search(rf'^def por_{X}_{i}\(o: .*?\) -> Data: DK\.Or2\((\w+)_{X}_(\d+)\(o\), (\w+)_{X}_(\d+)\(o\)\)$', vsrc, re.M)
        call = lambda kind, j, a: f'arm{j}(o, {a}, hs)' if kind == 'pc' else f'rp{j}(o, {a}, hs)'  # noqa: E731
        L.append(f'''def rp{i}(-o: {D}, +r: RT.por_{X}_{i}(o), +hs: SU(o)) -> {G('o')}:
  match r:
    case Inl{{a}}: {call(b.group(1), b.group(2), 'a')}
    case Inr{{b}}: {call(b.group(3), b.group(4), 'b')}
''')
    defs = f'''# the premise: the selected arm's storage premises (a progressive container arm's EQ.PREM_Arm)
def SU(o: {D}) -> Data:
  match o:
{chr(10).join(su)}

''' + '\n'.join(L)
    body = '  rp0(o, rep, hs)' if pors else '  arm0(o, rep, hs)'
    imps = ['import ../proofs/obj/root_gtypes2.bend as RT', 'import ../proofs/obj/root_gnames.bend as RN', 'import ../proofs/obj/vu32.bend as VU',
            'import ../proofs/obj/len_bridge.bend as LB', 'import ../proofs/obj/vbitb.bend as VBB', 'import ../types/generic_obj.bend as T',
            'import ./e2e_encq.bend as EQ'] + [f'import ../proofs/obj/{p[2:]} as {al}' for p, al in re.findall(r'^import (\./big_encx_\w+_iface\.bend) as (EA_\w+)$', ci, re.M)]
    return defs, body, imps, f'+rep: RT.rep_{X}(o), +hs: SU(o)'


for _X in ('GuAD91DEB870', 'Gu6DDF182530'):
    MWP[_X] = mwp_union_n
    VENC_SHAPES[_X] = venc_mw
    VENC_PREMISE[_X] = f'rep: RT.rep_{_X}(o) and hs: SU(o) (a progressive container arm\'s storage premises, e2e_encq.PREM_Arm; none for a uint8 arm)'


CPA['proglist_SmallTestStruct_d.pl_Gc4ED9619F50_Seq'] = ('rep_pl_Gc4ED9619F50', 'SmallTestStruct_d.Gc4ED9619F50', 'FD.array__thaw(SmallTestStruct_d.Gc4ED9619F50, {t})')
CPA['proglist_proglist_VarTestStruct_d.pl_pl_Gc465214E502_Seq'] = ('rep_pl_pl_Gc465214E502', 'RT.MB<RT.M_pl_Gc465214E502>', 'RT.am_pl_pl_Gc465214E502({t})')
CPX['Gc221EC01D83'] = {'mods': ['ProgressiveTestStruct_d:ProgressiveTestStruct_def_generated', 'SmallTestStruct_d:SmallTestStruct_def_generated',
                                'proglist_SmallTestStruct_d:proglist_SmallTestStruct_def_generated',
                                'proglist_proglist_VarTestStruct_d:proglist_proglist_VarTestStruct_def_generated'],
                       'hmod': 'ProgressiveTestStruct_h:ProgressiveTestStruct_hashtreeroot_generated', 'rt': 'root_gtypes2', 'gv': 'gvalid_gtypes2',
                       'fields': [('w', 'O.Words'), ('l', 'O.Words'), ('q', 'proglist_SmallTestStruct_d.pl_Gc4ED9619F50_Seq'),
                                  ('q', 'proglist_proglist_VarTestStruct_d.pl_pl_Gc465214E502_Seq')]}
VROOT_SHAPES['Gc221EC01D83'] = vroot_complex

CPA['list_ProgressiveSingleFieldContainerTestStruct_10_d.l10_GpF350A3C486_Seq'] = ('rep_l10_GpF350A3C486', 'ProgressiveSingleFieldContainerTestStruct_d.GpF350A3C486',
                                                                                  'FD.array__thaw(ProgressiveSingleFieldContainerTestStruct_d.GpF350A3C486, {t})')
CPA['proglist_ProgressiveVarTestStruct_d.pl_Gp66304057C3_Seq'] = ('rep_pl_Gp66304057C3', 'RT.MB<RT.M_Gp66304057C3>', 'RT.am_pl_Gp66304057C3({t})')
CPX['Gp8A7851175B'] = {'mods': ['ProgressiveComplexTestStruct_d:ProgressiveComplexTestStruct_def_generated', 'SmallTestStruct_d:SmallTestStruct_def_generated',
                                'proglist_SmallTestStruct_d:proglist_SmallTestStruct_def_generated',
                                'proglist_proglist_VarTestStruct_d:proglist_proglist_VarTestStruct_def_generated',
                                'ProgressiveSingleFieldContainerTestStruct_d:ProgressiveSingleFieldContainerTestStruct_def_generated',
                                'list_ProgressiveSingleFieldContainerTestStruct_10_d:list_ProgressiveSingleFieldContainerTestStruct_10_def_generated',
                                'proglist_ProgressiveVarTestStruct_d:proglist_ProgressiveVarTestStruct_def_generated'],
                       'hmod': 'ProgressiveComplexTestStruct_h:ProgressiveComplexTestStruct_hashtreeroot_generated', 'rt': 'root_gtypes2', 'gv': 'gvalid_gtypes2', 'pc': True,
                       'fields': [('u', 'U32'), ('l', 'O.Words'), ('b', 'O.Bits'), ('l', 'O.Words'), ('q', 'proglist_SmallTestStruct_d.pl_Gc4ED9619F50_Seq'),
                                  ('q', 'proglist_proglist_VarTestStruct_d.pl_pl_Gc465214E502_Seq'),
                                  ('a', 'list_ProgressiveSingleFieldContainerTestStruct_10_d.l10_GpF350A3C486_Seq'),
                                  ('q', 'proglist_ProgressiveVarTestStruct_d.pl_Gp66304057C3_Seq')]}
VROOT_SHAPES['Gp8A7851175B'] = vroot_complex
