"""Spec-connected codec laws of the fixed-size names with array-backed storage
beyond 512 words (called from codegen/spec_laws.py).

A buffer of such a name is a perfect Base array tree; the laws are stated for
EVERY perfect tree of the loader's depth (each half or quarter a free tree),
and the storage of an object for every perfect storage tree (its padding half
free). The runtime copy and emit loops are proved once, for symbolic counts,
in proofs/obj/arr_copy.bend and arr_emit.bend (codegen/arr_laws.py); the spec
side of word lists of symbolic length in arr_spec.bend and arr_vec.bend.

Closed sizes are never compared on the stock checker (it expands a closed Nat
of 2^15 or more in unary and overflows): the schema is a variable `s` with the
hypothesis `s == Spec.<N>()` (as in the root laws), every closed fact is a Bool
that the checker evaluates, and an emit count above 2^14 words is a variable
`k` with `k == <count>`.
"""

TV = 'F.array__Tree<U32>'



def HK(p, words):
    """oct(words >> 3) == 2^p, closed from words == u32__pow2u(p) (no unary 2^p)."""
    assert words == 1 << p and p >= 3
    return f'AC.oct_pow({words}, {p}n, {p - 3}n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}})'


def PN(words, p):
    """to_nat(words) == 2^p, likewise."""
    assert words == 1 << p
    return f'AC.pow2u_is({words}, {p}n, {{==}}, {{==}})'



def split_params(ps):
    """'+a: T, +b: {x == y : U}' -> ['+a: T', ...] (commas at depth 0 only)."""
    out, cur, d = [], '', 0
    for c in ps:
        if c in '([{<':
            d += 1
        elif c in ')]}>':
            d -= 1
        if c == ',' and d == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += c
    if cur.strip():
        out.append(cur.strip())
    return out


def pname(p):
    return p.split(':')[0].strip().lstrip('+-~').strip()

def th(t):
    return f'F.array__thaw(U32, {t})'


def slots(t):
    return f'F.array__slots(U32, {t})'


def pf(d, t):
    return f'{{F.array__perfect(U32, {d}n, {t}) == True{{}} : Bool}}'


def trees(names, d):
    return ', '.join(f'+{t}: {TV}' for t in names) + ', ' + ', '.join(f'+p{t}: {pf(d, t)}' for t in names)


def andp(d, a, b):
    return f'F.logic__and_intro(F.array__perfect(U32, {d}n, {a}), F.array__perfect(U32, {d}n, {b}), p{a}, p{b})'


def bfact(spec, pred):
    """A Bool fact about the schema variable s, from the frozen schema by evaluation."""
    return (f'F.logic__subst(S.Schema, z => {{{pred.replace("(s)", "(z)")} == True{{}} : Bool}}, {spec}, s, '
            f'Equal.sym(S.Schema, s, {spec}, es), {{==}})')


def sfact(spec, proj, val):
    return (f'F.logic__subst(S.Schema, z => {{{proj.replace("(s)", "(z)")} == {val} : S.Schema}}, {spec}, s, '
            f'Equal.sym(S.Schema, s, {spec}, es), {{==}})')


HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O',
        'import ../../types/fulu_obj.bend as T', 'import ../../types/schema.bend as S',
        'import ../../types/primitive.bend as P', 'import ../../spec/layout.bend as Layout',
        'import ../../spec/codec.bend as Codec', 'import ../../spec/schema.bend as SSC',
        'import ../../spec/decoding_relation.bend as Decoding', 'import ../../spec/fulu_schemas.bend as Spec',
        'import ../../proofs/compact/found.bend as F', 'import ./spec_fixed.bend as SF',
        'import ./schema_shapes.bend as SH', 'import ./arr_copy.bend as AC', 'import ./arr_emit.bend as AE',
        'import ./arr_spec.bend as AS', 'import ./arr_vec.bend as AV']


# Sizes as powers of two with the exponent a parameter (pair_vec): 2^p words, 2^(p+2) bytes a field,
# 2^(p+3) the value. Closed as literals (262144n, 524288n, NB.fits(4n, ..)) they were evaluated in
# unary (HistoricalBatch_spec_parts: 64 M whnf steps, 3.4 M Nat steps).
PW_IMPORTS = ['import ../../proofs/compact/arith.bend as A', 'import ../../spec/nat_bytes.bend as NB', 'import ./vfits.bend as VFT']


def PW(k):
    return f'F.spec_common__pow2({k}n)'


def WQ(p):
    return f'ieq(A.quad({PW(p)}), {PW(p + 2)}, eq_q({p}n, {p + 2}n, {{==}}))'


PW_DEFS = [
    '# sizes as powers of two, the exponents parameters (never built in unary)',
    'def eq_q(+d: Nat, +r: Nat, +er: {r == 2n+d : Nat}) -> {A.quad(F.spec_common__pow2(d)) == F.spec_common__pow2(r) : Nat}:',
    '  %Equal.sym(Nat, r, 2n+d, er) : {A.quad(F.spec_common__pow2(d)) == F.spec_common__pow2(_) : Nat}',
    '  {==}',
    'def eq_d(+d: Nat, +r: Nat, +er: {r == 1n+d : Nat}) -> {Nat.add(F.spec_common__pow2(d), Nat.add(F.spec_common__pow2(d), 0n)) == F.spec_common__pow2(r) : Nat}:',
    '  %Equal.sym(Nat, r, 1n+d, er) : {Nat.add(F.spec_common__pow2(d), Nat.add(F.spec_common__pow2(d), 0n)) == F.spec_common__pow2(_) : Nat}',
    '  Equal.sym(Nat, Nat.double(F.spec_common__pow2(d)), Nat.add(F.spec_common__pow2(d), Nat.add(F.spec_common__pow2(d), 0n)), F.u32__double_pow(F.spec_common__pow2(d)))',
    'def ieq(+a: Nat, +b: Nat, +e: {a == b : Nat}) -> {Nat.is_eq(a, b) == True{} : Bool}:',
    '  F.logic__subst(Nat, z => {Nat.is_eq(a, z) == True{} : Bool}, a, b, e, F.nat__is_eq_refl(a))',
    'def fitp(+r: Nat, +hr: {Nat.is_lt(r, 32n) == True{} : Bool}) -> {NB.fits(4n, Nat.add(F.spec_common__pow2(r), 0n)) == True{} : Bool}:',
    '  %Equal.sym(Nat, Nat.add(F.spec_common__pow2(r), 0n), F.spec_common__pow2(r), F.nat__add_zero(F.spec_common__pow2(r))) : {NB.fits(4n, _) == True{} : Bool}',
    '  VFT.fits4(r, F.spec_common__pow2(r), F.nat__le_refl(F.spec_common__pow2(r)), hr)',
    '']


def emit_var(w, name, T, d, n, words, law):
    """view law with the word count as a variable k == words."""
    K = words - 1
    w(f'  AE.emit_all({d}n, {T}, {n}, k, {K}n,')
    w(f'    F.logic__subst(U32, z => {{Nat.is_eq(U32.to_nat(z), 1n+{K}n) == True{{}} : Bool}}, {words}, k, Equal.sym(U32, k, {words}, ek), {{==}}),')


def reject(w, name, n, okname, R):
    w(f'# every size other than {n} is refused')
    w(f'def {name}_spec_reject(buf: B.Buf, +m: U32, e: {{U32.is_eq(m, {n}) == False{{}} : Bool}})')
    w(f'    -> {{T.{name}_decode(buf, m) == (buf, None{{}}) : B.Buf & Maybe<&1, {R}>}}:')
    w(f'  %Equal.sym(Bool, U32.is_eq(m, {n}), False{{}}, e) : {{T.{name}_built(m, T.{okname}_ok_len(_, buf, 0)) == (buf, None{{}}) : B.Buf & Maybe<&1, {R}>}}')
    w('  {==}')
    w('')


def unique(w, name, hdr, args, bytes_, val, legal=None, by_var=False):
    spec = f'Spec.{name}()'
    # the validator's acceptance of the schema by evaluation, carried to s (decode_unique.valid_unique:
    # image_unique's legality form imports the compatibility_* chain and every name's legality witness)
    lg = '{==}'
    if by_var:
        # the bytes as a variable `by` equal to them: with the 212 literal field words of
        # BlobSidecar, a parameter typed Decoding.decodes(s, <those bytes>, v) overflows
        # stock Bend's stack; the law is the same (by := the bytes, eby := {==})
        w(f'def {name}_spec_unique({hdr}, +by: +List<U32>, +eby: {{by == {bytes_} : +List<U32>}}, +v: S.Value, spec: Decoding.decodes(s, by, v))')
        w(f'    -> {{v == {val} : S.Value}}:')
        w(f'  E.valid_unique(s, by, v, {val},')
        w(f'    F.logic__subst(S.Schema, z => {{I.valid(z) == True{{}} : Bool}}, {spec}, s, Equal.sym(S.Schema, s, {spec}, es), {lg}),')
        w(f'    spec, F.logic__subst(+List<U32>, z => Decoding.decodes(s, z, {val}), {bytes_}, by, Equal.sym(+List<U32>, by, {bytes_}, eby),')
        w(f'      SF.encoding_of_parts(s, {val}, {bytes_}, C.{name}_spec_parts({args}))))')
        w('')
        return
    w(f'def {name}_spec_unique({hdr}, +v: S.Value, spec: Decoding.decodes(s, {bytes_}, v))')
    w(f'    -> {{v == {val} : S.Value}}:')
    w(f'  E.valid_unique(s, {bytes_}, v, {val},')
    w(f'    F.logic__subst(S.Schema, z => {{I.valid(z) == True{{}} : Bool}}, {spec}, s, Equal.sym(S.Schema, s, {spec}, es), {lg}),')
    w(f'    spec, C.{name}_spec_encode({args}))')
    w('')


def blob(name, p, okname):
    """A byte vector of 2^p words (Blob)."""
    n = 4 << p
    words = 1 << p
    L = list(HEAD) + ['', '# GENERATED by codegen/spec_laws.py (spec_arr.blob). Do not edit.',
                      f'# {name}: a byte vector of {n} bytes = 2^{p} words, array-backed storage.', '']
    w = L.append
    R = 'O.Words'
    buf = lambda t: f'B.Buf{{{th(t)}, {n}}}'
    dec = f'O.Words{{ANode{{{th("t")}, Array.new(U32, {p}n, 0)}}, {n}}}'
    W = slots('t')
    w(f'# decoding any buffer of {n} bytes (every perfect tree t of depth {p}) accepts; the')
    w('# object holds the words of t, then zero storage')
    w(f'def {name}_spec_decode(+t: {TV}, +pt: {pf(p, "t")})')
    w(f'    -> {{T.{name}_decode({buf("t")}, {n}) == ({buf("t")}, Some{{{dec}}}) : B.Buf & Maybe<&1, {R}>}}:')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({words}, 0, 0, Array.new(U32, {p + 1}n, 0), {th("t")}), (ANode{{{th("t")}, Array.new(U32, {p}n, 0)}}, {th("t")}),')
    w(f'      AC.zl1({p}n, {words}, 0, 0, t, {{==}}, {{==}}, {HK(p, words)}, {{==}}, {{==}}, pt)) :')
    w(f'    {{T.{name}_some(O.ci_fin({n}, {n}, _)) == ({buf("t")}, Some{{{dec}}}) : B.Buf & Maybe<&1, {R}>}}')
    w('  {==}')
    w('')
    w(f'# the bytes of that buffer (B.emit) are the limbs of the words of t')
    w(f'def {name}_spec_view(+t: {TV}, +pt: {pf(p, "t")}, +k: U32, +ek: {{k == {words} : U32}})')
    w(f'    -> {{B.emit({buf("t")}, 0, k) == ({buf("t")}, SF.limbs({W})) : B.Buf & +List<U32>}}:')
    emit_var(w, name, 't', p, n, words, 'view')
    w('    {==}, {==}, {==}, pt)')
    w('')
    w(f'# the buffer the loader builds from the bytes of any {words} words is that tree')
    w(f'def {name}_spec_input(+t: {TV}, +pt: {pf(p, "t")})')
    w(f'    -> {{T.{name}_decode(B.fill_at(B.alloc({n}), 0, SF.limbs({W})), {n}) == ({buf("t")}, Some{{{dec}}}) : B.Buf & Maybe<&1, {R}>}}:')
    w(f'  %Equal.sym(B.Buf, B.fill_at(B.alloc({n}), 0, SF.limbs({W})), {buf("t")}, AE.load_all({p}n, t, {n}, {{==}}, {{==}}, pt)) :')
    w(f'    {{T.{name}_decode(_, {n}) == ({buf("t")}, Some{{{dec}}}) : B.Buf & Maybe<&1, {R}>}}')
    w(f'  {name}_spec_decode(t, pt)')
    w('')
    obj = f'O.Words{{ANode{{{th("l")}, {th("r")}}}, {n}}}'
    w(f'# the encoder emits the limbs of the object\'s words (storage [l | r], r free)')
    w(f'def {name}_spec_bytes({trees(["l", "r"], p)}, +k: U32, +ek: {{k == {words} : U32}})')
    w(f'    -> {{SF.emitted({R}, T.{name}_encode({obj}), k) == ({obj}, SF.limbs({slots("l")})) : {R} & +List<U32>}}:')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({words}, 0, 0, Array.new(U32, {p}n, 0), {th("F.TNode{l, r}")}), ({th("l")}, {th("F.TNode{l, r}")}),')
    w(f'      AC.ov({p}n, {words}, 0, 0, l, r, {{==}}, {{==}}, {HK(p, words)}, {{==}}, {{==}}, pl, pr)) :')
    w(f'    {{SF.emitted({R}, T.{name}_enc_out(O.put_fin({n}, _)), k) == ({obj}, SF.limbs({slots("l")})) : {R} & +List<U32>}}')
    w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit(B.Buf{{{th("l")}, {n}}}, 0, k), (B.Buf{{{th("l")}, {n}}}, SF.limbs({slots("l")})), {name}_spec_view(l, pl, k, ek)) :')
    w(f'    {{({obj}, SF.listed(_)) == ({obj}, SF.limbs({slots("l")})) : {R} & +List<U32>}}')
    w('  {==}')
    w('')
    spec = f'Spec.{name}()'
    hdr = f'+t: {TV}, +pt: {pf(p, "t")}, +s: S.Schema, +es: {{s == {spec} : S.Schema}}'
    val = f'S.BytesValue{{SF.limbs({W})}}'
    w(f'# the spec\'s parts of the value of words t at the schema are one fixed part: those bytes')
    w(f'def {name}_spec_parts({hdr})')
    w(f'    -> {{Codec.parts({val}, s) == Some{{[S.Fixed{{SF.limbs({W})}}]}} : Maybe<&2, +List<S.Part>>}}:')
    w(f'  AS.bv_parts(s, {W}, {n}n, {bfact(spec, "SH.is_ByteVector(s)")},')
    w(f'    {bfact(spec, f"Nat.is_eq(SH.ByteVector_length(s), {n}n)")},')
    w(f'    AS.wlen_tree({p}n, t, {n}n, pt, {{==}}), {{==}}, {{==}})')
    w('')
    w(f'# encoder soundness against spec/codec.bend: the bytes are the canonical encoding of the value')
    w(f'def {name}_spec_encode({hdr})')
    w(f'    -> Decoding.decodes(s, SF.limbs({W}), {val}):')
    w(f'  SF.encoding_of_parts(s, {val}, SF.limbs({W}), {name}_spec_parts(t, pt, s, es))')
    w('')
    reject(w, name, n, okname, R)
    U = []
    unique(U.append, name, hdr, 't, pt, s, es', f'SF.limbs({W})', val)
    return '\n'.join(L) + '\n', U


def pair_vec(name, p, e, fname):
    """A container of two vectors of byte vectors of e words, each field 2^p words
    (HistoricalBatch: two Vector[Root, 8192]). `fname` is the field type's prefix."""
    words = 1 << p          # words of one field
    fb = 4 * words          # bytes of one field
    n = 2 * fb
    k = words // e          # elements of one field
    R = f'T.{name}'
    L = list(HEAD) + PW_IMPORTS + ['', '# GENERATED by codegen/spec_laws.py (spec_arr.pair_vec). Do not edit.',
                      f'# {name}: two vectors of {k} byte vectors of {4 * e} bytes, {fb} bytes each, array-backed.', ''] + PW_DEFS
    w = L.append
    B2 = lambda a, b: f'B.Buf{{ANode{{{th(a)}, {th(b)}}}, {n}}}'
    dec = (f'{R}{{O.Words{{ANode{{{th("u")}, Array.new(U32, {p}n, 0)}}, {fb}}}, '
           f'O.Words{{ANode{{{th("v")}, Array.new(U32, {p}n, 0)}}, {fb}}}}}')
    RT = f'B.Buf & Maybe<&1, {R}>'
    RHS = f'({B2("u", "v")}, Some{{{dec}}})'
    w(f'# decoding any buffer of {n} bytes [u | v] (u, v every perfect tree of depth {p}) accepts')
    w(f'def {name}_spec_decode({trees(["u", "v"], p)})')
    w(f'    -> {{T.{name}_decode({B2("u", "v")}, {n}) == {RHS} : {RT}}}:')
    A1 = f'ANode{{{th("u")}, Array.new(U32, {p}n, 0)}}'
    # every step names the reader's own terms (see arr_copy read_al): no copy loop is run
    WSn = f'ANode{{{th("u")}, {th("v")}}}'
    N17 = f'Array.new(U32, {p + 1}n, 0)'
    o0, o1 = '(0 + 0 : U32)', f'(0 + {fb} : U32)'
    NWt = f'U32.shrn(({fb} + 3 : U32), 2n)'
    HKt = f'AC.oct_pow({NWt}, {p}n, {p - 3}n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}})'
    P0 = f'({A1}, {WSn})'
    P1 = f'(ANode{{{th("v")}, Array.new(U32, {p}n, 0)}}, {WSn})'
    w(f'  %Equal.sym(B.Buf & O.Words, O.copy_into(B.Buf{{{WSn}, {n}}}, {o0}, {fb}, {N17}), O.ci_fin({n}, {fb}, {P0}),')
    w(f'      AC.read_al({WSn}, {N17}, {n}, {o0}, {fb}, {P0}, {{==}}, {{==}},')
    w(f'        AC.zl2n({p}n, {NWt}, U32.shrn({o0}, 2n), 0, u, v, {{==}}, {{==}}, {HKt}, {{==}}, {{==}}, pu, pv))) :')
    w(f'    {{T.{name}_some(T.{name}_rd0(0, {n}, _)) == {RHS} : {RT}}}')
    w(f'  %Equal.sym(B.Buf & O.Words, O.copy_into(B.Buf{{{WSn}, {n}}}, {o1}, {fb}, {N17}), O.ci_fin({n}, {fb}, {P1}),')
    w(f'      AC.read_al({WSn}, {N17}, {n}, {o1}, {fb}, {P1}, {{==}}, {{==}},')
    w(f'        AC.zl3n({p}n, {NWt}, U32.shrn({o1}, 2n), 0, u, v, {{==}}, {{==}}, {HKt}, AC.pow2u_is(U32.shrn({o1}, 2n), {p}n, {{==}}, {{==}}), {{==}}, pu, pv))) :')
    w(f'    {{T.{name}_some(T.{name}_rd1(0, {n}, O.Words{{{A1}, {fb}}}, _)) == {RHS} : {RT}}}')
    w('  {==}')
    w('')
    w(f'# the bytes of that buffer are the limbs of the words of u, then v')
    w(f'def {name}_spec_view({trees(["u", "v"], p)}, +k: U32, +ek: {{k == {2 * words} : U32}})')
    w(f'    -> {{B.emit({B2("u", "v")}, 0, k) == ({B2("u", "v")}, SF.limbs({slots("F.TNode{u, v}")})) : B.Buf & +List<U32>}}:')
    emit_var(w, name, 'F.TNode{u, v}', p + 1, n, 2 * words, 'view')
    w(f'    {{==}}, {{==}}, {{==}}, {andp(p, "u", "v")})')
    w('')
    w(f'# the buffer the loader builds from the bytes of any {2 * words} words')
    w(f'def {name}_spec_input({trees(["u", "v"], p)})')
    w(f'    -> {{T.{name}_decode(B.fill_at(B.alloc({n}), 0, SF.limbs({slots("F.TNode{u, v}")})), {n}) == {RHS} : {RT}}}:')
    w(f'  %Equal.sym(B.Buf, B.fill_at(B.alloc({n}), 0, SF.limbs({slots("F.TNode{u, v}")})), {B2("u", "v")}, AE.load_all({p + 1}n, F.TNode{{u, v}}, {n}, {{==}}, {{==}}, {andp(p, "u", "v")})) :')
    w(f'    {{T.{name}_decode(_, {n}) == {RHS} : {RT}}}')
    w(f'  {name}_spec_decode(u, v, pu, pv)')
    w('')
    BR = f'O.Words{{ANode{{{th("l1")}, {th("r1")}}}, {fb}}}'
    SR = f'O.Words{{ANode{{{th("l2")}, {th("r2")}}}, {fb}}}'
    OBJ = f'{R}{{{BR}, {SR}}}'
    BRHS = f'({OBJ}, SF.limbs({slots("F.TNode{l1, l2}")}))'
    TY = f'{R} & +List<U32>'
    ctx = lambda inner: f'{{SF.emitted({R}, T.{name}_enc_out(T.{name}_put_drop({inner})), k) == {BRHS} : {TY}}}'
    A1 = f'ANode{{{th("l1")}, Array.new(U32, {p}n, 0)}}'
    w(f'# the encoder emits the limbs of the words of both fields (storage [l | r], r free)')
    w(f'def {name}_spec_bytes({trees(["l1", "r1", "l2", "r2"], p)}, +k: U32, +ek: {{k == {2 * words} : U32}})')
    w(f'    -> {{SF.emitted({R}, T.{name}_encode({OBJ}), k) == {BRHS} : {TY}}}:')
    vok = lambda l, r: f'AC.vok({p + 1}n, F.TNode{{{l}, {r}}}, {fb}, {fb}, {fb}, False{{}}, {4 * e}, {{==}}, {{==}}, {{==}}, {{==}}, {andp(p, l, r)})'
    w(f'  %Equal.sym(O.Words & Bool, O.words_ok({BR}, {fb}, {fb}, False{{}}, {4 * e}), ({BR}, True{{}}), {vok("l1", "r1")}) :')
    w('    ' + ctx(f'T.{name}_pw0(0, 0, {SR}, T.{fname}_pk(Array.new(U32, {p + 1}n, 0), (0 + 0 : U32), _))'))
    AN1, AN2 = f'ANode{{{th("l1")}, {th("r1")}}}', f'ANode{{{th("l2")}, {th("r2")}}}'
    N17 = f'Array.new(U32, {p + 1}n, 0)'
    o0, o1 = '(0 + 0 : U32)', f'(0 + {fb} : U32)'
    NWt = f'U32.shrn(({fb} + 3 : U32), 2n)'
    HKt = f'AC.oct_pow({NWt}, {p}n, {p - 3}n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}})'
    E0 = f'({A1}, {AN1})'
    E1 = f'(ANode{{{th("l1")}, {th("l2")}}}, {AN2})'
    w(f'  %Equal.sym(Array<U32> & O.Words, O.put_words({N17}, {o0}, {BR}), O.put_fin({fb}, {E0}),')
    w(f'      AC.put_al({N17}, {AN1}, {o0}, {fb}, {E0}, {{==}}, {{==}}, {{==}},')
    w(f'        AC.zl2n({p}n, {NWt}, 0, U32.shrn({o0}, 2n), l1, r1, {{==}}, {{==}}, {HKt}, {{==}}, {{==}}, pl1, pr1))) :')
    w('    ' + ctx(f'T.{name}_pw0(0, 0, {SR}, T.{fname}_pk_ok(_))'))
    w(f'  %Equal.sym(O.Words & Bool, O.words_ok({SR}, {fb}, {fb}, False{{}}, {4 * e}), ({SR}, True{{}}), {vok("l2", "r2")}) :')
    w('    ' + ctx(f'T.{name}_pw1(0, 0, {BR}, T.{fname}_pk({A1}, (0 + {fb} : U32), _))'))
    w(f'  %Equal.sym(Array<U32> & O.Words, O.put_words({A1}, {o1}, {SR}), O.put_fin({fb}, {E1}),')
    w(f'      AC.put_al({A1}, {AN2}, {o1}, {fb}, {E1}, {{==}}, {{==}}, {{==}},')
    w(f'        AC.zrn({p}n, {NWt}, 0, U32.shrn({o1}, 2n), l1, l2, r2, {{==}}, {{==}}, {HKt}, {{==}}, AC.pow2u_is(U32.shrn({o1}, 2n), {p}n, {{==}}, {{==}}), pl1, pl2, pr2))) :')
    w('    ' + ctx(f'T.{name}_pw1(0, 0, {BR}, T.{fname}_pk_ok(_))'))
    w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit(B.Buf{{ANode{{{th("l1")}, {th("l2")}}}, {n}}}, 0, k), (B.Buf{{ANode{{{th("l1")}, {th("l2")}}}, {n}}}, SF.limbs({slots("F.TNode{l1, l2}")})),')
    w(f'      {name}_spec_view(l1, l2, pl1, pl2, k, ek)) :')
    w(f'    {{({OBJ}, SF.listed(_)) == {BRHS} : {TY}}}')
    w('  {==}')
    w('')
    # spec side
    spec = f'Spec.{name}()'
    W1, W2 = slots('l1'), slots('l2')
    VAL = f'S.Sequence{{S.Items{{S.Sequence{{AV.ch{e}({W1})}}, S.Items{{S.Sequence{{AV.ch{e}({W2})}}, S.EmptyItems{{}}}}}}}}'
    PT = 'Maybe<&2, +List<S.Part>>'
    FL = f'SF.flat([{W1}, {W2}])'
    RHSF = f'Some{{[S.Fixed{{{FL}}}]}}'
    fs = 'SH.Container_fields(s)'
    h1 = f'SH.Chain_head({fs})'
    t1 = f'SH.Chain_tail({fs})'
    h2 = f'SH.Chain_head({t1})'
    t2 = f'SH.Chain_tail({t1})'
    BV = f'S.ByteVector{{{4 * e}n}}'
    hdr = f'{trees(["l1", "l2"], p)}, +s: S.Schema, +es: {{s == {spec} : S.Schema}}'
    BY = f'SF.limbs({slots("F.TNode{l1, l2}")})'
    w(f'# the spec\'s parts of the value of the words of l1, l2 at the schema: those bytes')
    w(f'def {name}_spec_parts({hdr})')
    w(f'    -> {{Codec.parts({VAL}, s) == Some{{[S.Fixed{{{BY}}}]}} : {PT}}}:')
    g = lambda sch, rhs: f'{{Codec.parts({VAL}, {sch}) == {rhs} : {PT}}}'
    w(f'  %Equal.sym(+List<U32>, SF.limbs(F.spec_common__append(U32, {W1}, {W2})), List.append(&2, U32, SF.limbs({W1}), SF.limbs({W2})), AS.limbs_app({W1}, {W2})) :')
    w('    ' + g('s', 'Some{[S.Fixed{_}]}'))
    w(f'  %AS.app_nil(SF.limbs({W2})) :')
    w('    ' + g('s', f'Some{{[S.Fixed{{List.append(&2, U32, SF.limbs({W1}), _)}}]}}'))
    V1 = f'S.Vector{{{BV}, SH.Vector_length({h1})}}'
    V2 = f'S.Vector{{{BV}, SH.Vector_length({h2})}}'
    names = 'SH.Container_names(s)'
    steps = [
        (f'Equal.sym(S.Schema, s, S.Container{{{names}, {fs}}}, SH.Container_shape(s, {bfact(spec, "SH.is_Container(s)")}))', '_'),
        (f'Equal.sym(S.Schema, {fs}, S.Chain{{{h1}, {t1}}}, SH.Chain_shape({fs}, {bfact(spec, f"SH.is_Chain({fs})")}))', f'S.Container{{{names}, _}}'),
        (f'Equal.sym(S.Schema, {t1}, S.Chain{{{h2}, {t2}}}, SH.Chain_shape({t1}, {bfact(spec, f"SH.is_Chain({t1})")}))', f'S.Container{{{names}, S.Chain{{{h1}, _}}}}'),
        (f'Equal.sym(S.Schema, {t2}, S.End{{}}, SH.End_shape({t2}, {bfact(spec, f"SH.is_End({t2})")}))', f'S.Container{{{names}, S.Chain{{{h1}, S.Chain{{{h2}, _}}}}}}'),
        (f'Equal.sym(S.Schema, {h1}, S.Vector{{SH.Vector_element({h1}), SH.Vector_length({h1})}}, SH.Vector_shape({h1}, {bfact(spec, f"SH.is_Vector({h1})")}))', f'S.Container{{{names}, S.Chain{{_, S.Chain{{{h2}, S.End{{}}}}}}}}'),
        (f'Equal.sym(S.Schema, SH.Vector_element({h1}), {BV}, {sfact(spec, f"SH.Vector_element({h1})", BV)})', f'S.Container{{{names}, S.Chain{{S.Vector{{_, SH.Vector_length({h1})}}, S.Chain{{{h2}, S.End{{}}}}}}}}'),
        (f'Equal.sym(S.Schema, {h2}, S.Vector{{SH.Vector_element({h2}), SH.Vector_length({h2})}}, SH.Vector_shape({h2}, {bfact(spec, f"SH.is_Vector({h2})")}))', f'S.Container{{{names}, S.Chain{{{V1}, S.Chain{{_, S.End{{}}}}}}}}'),
        (f'Equal.sym(S.Schema, SH.Vector_element({h2}), {BV}, {sfact(spec, f"SH.Vector_element({h2})", BV)})', f'S.Container{{{names}, S.Chain{{{V1}, S.Chain{{S.Vector{{_, SH.Vector_length({h2})}}, S.End{{}}}}}}}}'),
    ]
    for eq, sch in steps:
        w(f'  %{eq} :')
        w('    ' + g(sch, RHSF))
    FIELDS = f'S.Chain{{{V1}, S.Chain{{{V2}, S.End{{}}}}}}'
    agg = lambda a, b: f'{{Codec.aggregate(Codec.concatenate({a}, Codec.concatenate({b}, Some{{[]}})), SSC.fixed_size({FIELDS})) == {RHSF} : {PT}}}'

    def vp(V, h, l, W):
        kf = bfact(spec, f'Nat.is_eq(SH.Vector_length({h}), {k}n)')
        return (f'AV.vparts{e}({V}, {W}, {k}n, {PW(p)}, {PW(p + 2)}, {{==}}, {{==}}, {kf}, {{==}}, AS.len_tree({p}n, {l}, {PW(p)}, p{l}, F.nat__is_eq_refl({PW(p)})), {{==}}, '
                f'AS.wlen_eq({p}n, {l}, {PW(p + 2)}, p{l}, {WQ(p)}), fitp({p + 2}n, {{==}}))')
    P1 = f'Codec.parts(S.Sequence{{AV.ch{e}({W1})}}, {V1})'
    P2 = f'Codec.parts(S.Sequence{{AV.ch{e}({W2})}}, {V2})'
    F1 = f'Some{{[S.Fixed{{SF.limbs({W1})}}]}}'
    F2 = f'Some{{[S.Fixed{{SF.limbs({W2})}}]}}'
    w(f'  %Equal.sym({PT}, {P1}, {F1}, {vp(V1, h1, "l1", W1)}) :')
    w('    ' + agg('_', P2))
    w(f'  %Equal.sym({PT}, {P2}, {F2}, {vp(V2, h2, "l2", W2)}) :')
    w('    ' + agg(F1, '_'))
    x = f'Nat.add(Nat.mul(SH.Vector_length({h1}), {4 * e}n), Nat.add(Nat.mul(SH.Vector_length({h2}), {4 * e}n), 0n))'
    ea = lambda W, l: f'Equal.trans(Nat, List.length(&2, U32, SF.limbs({W})), SF.wlen({W}), {PW(p + 2)}, AS.len_limbs({W}), AS.wlen_eq({p}n, {l}, {PW(p + 2)}, p{l}, {WQ(p)}))'
    w(f'  AS.agg([{W1}, {W2}], {x}, {PW(p + 3)},')
    w(f'    AS.add2(List.length(&2, U32, SF.limbs({W1})), List.length(&2, U32, SF.limbs({W2})), {PW(p + 2)}, {PW(p + 2)}, {PW(p + 3)}, {ea(W1, "l1")}, {ea(W2, "l2")}, '
      f'ieq(Nat.add({PW(p + 2)}, Nat.add({PW(p + 2)}, 0n)), {PW(p + 3)}, eq_d({p + 2}n, {p + 3}n, {{==}}))), fitp({p + 3}n, {{==}}))')
    w('')
    w(f'# encoder soundness against spec/codec.bend')
    w(f'def {name}_spec_encode({hdr})')
    w(f'    -> Decoding.decodes(s, {BY}, {VAL}):')
    w(f'  SF.encoding_of_parts(s, {VAL}, {BY}, {name}_spec_parts(l1, l2, pl1, pl2, s, es))')
    w('')
    reject(w, name, n, name, R)
    U = []
    unique(U.append, name, hdr, 'l1, l2, pl1, pl2, s, es', BY, VAL)
    return '\n'.join(L) + '\n', U


UHEAD = ['import Base', 'import ../../types/schema.bend as S', 'import ../../spec/decoding_relation.bend as Decoding',
         'import ../../spec/fulu_schemas.bend as Spec', 'import ../../src/schema.bend as I',
         'import ../decode_unique.bend as E',
         'import ../../proofs/compact/found.bend as F', 'import ../../types/primitive.bend as P', './spec_fixed.bend as SF', './arr_vec.bend as AV']


def outputs(root):
    """{path: text} of the array-backed names' laws; `covered` names."""
    out = {}
    names = []
    for name, (text, u) in [('Blob', blob('Blob', 15, 'b131072')),
                            ('HistoricalBatch', pair_vec('HistoricalBatch', 16, 8, 'v8192_b32')),
                            ('SyncCommittee', sync_committee()),
                            ('BlobSidecar', blob_sidecar())]:
        out[root / f'proofs/obj/spec_arr_{name}.bend'] = text
        names.append((name, u))
    for name, (text, u) in [('vec_uint32_512', uvec('vec_uint32_512', 9, 1, 'v512_u32')),
                            ('vec_uint64_512', uvec('vec_uint64_512', 10, 2, 'v512_u64')),
                            ('vec_uint128_512', uvec('vec_uint128_512', 11, 4, 'v512_u128')),
                            ('vec_uint256_512', uvec('vec_uint256_512', 12, 8, 'v512_u256')),
                            ('vec_uint32_513', uvec_tail('vec_uint32_513', 1, 'v513_u32')),
                            ('vec_uint64_513', uvec_tail('vec_uint64_513', 2, 'v513_u64')),
                            ('vec_uint128_513', uvec_tail('vec_uint128_513', 4, 'v513_u128')),
                            ('vec_uint256_513', uvec_tail('vec_uint256_513', 8, 'v513_u256'))]:
        out[root / f'proofs/obj/spec_garr_{name}.bend'] = text
        gl = [x if x.startswith('import') else 'import ' + x for x in UHEAD]
        gl = [x.replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec')
               .replace('import ../../proofs/fulu_legality.bend as Legal', 'import ../type_validator_soundness.bend as VS') for x in gl]
        lines = gl + [f'import ./spec_garr_{name}.bend as C', '',
                 '# GENERATED by codegen/spec_laws.py (spec_arr). Do not edit.',
                 '# Completeness of the decoder\'s answer (decode_unique.valid_unique = decode_complete.image_unique,',
                 '# from the validator\'s acceptance of the generic schema).', ''] + u
        out[root / f'proofs/obj/spec_garr_unique_{name}.bend'] = '\n'.join(lines) + '\n'
        names.append((name, None))
    for name, u in names:
        if u is None:
            continue
        lines = [x if x.startswith('import') else 'import ' + x for x in UHEAD] + [f'import ./spec_arr_{name}.bend as C', '',
                 '# GENERATED by codegen/spec_laws.py (spec_arr). Do not edit.',
                 '# Completeness of the decoder\'s answer (decode_unique.valid_unique = decode_complete.image_unique,',
                 '# which END_TO_END.deserialize_unique is, from the validator\'s acceptance of the',
                 '# schema, carried to the schema variable s == Spec.<N>()).', ''] + u
        out[root / f'proofs/obj/spec_arr_unique_{name}.bend'] = '\n'.join(lines) + '\n'
    return out, [n for n, _ in names]


def ttree(leaves):
    if len(leaves) == 1:
        return f'F.TLeaf{{{leaves[0]}}}'
    h = len(leaves) // 2
    return f'F.TNode{{{ttree(leaves[:h])}, {ttree(leaves[h:])}}}'


def spine(d, leaf, q):
    """[leaf | q0 | q1 | ... | q_{d-1}]: a perfect tree of depth d whose first word is
    `leaf` (so Base.Array.size, which walks the leftmost path, computes), every
    other part a free tree q_j of depth j. Returns (term, perfect proof, params)."""
    t, p = f'F.TLeaf{{{leaf}}}', '{==}'
    for j in range(d):
        p = f'F.logic__and_intro(F.array__perfect(U32, {j}n, {t}), F.array__perfect(U32, {j}n, {q}{j}), {p}, p{q}{j})'
        t = f'F.TNode{{{t}, {q}{j}}}'
    params = f'+{leaf}: U32, ' + ', '.join(f'+{q}{j}: {TV}' for j in range(d)) + ', ' + ', '.join(f'+p{q}{j}: {pf(j, f"{q}{j}")}' for j in range(d))
    return t, p, params


def head_chunk(d, lo, leaves, c, zero=False):
    """[leaves (a literal tree of depth lo) | c_lo | ... | c_{d-1}] (or zero trees)."""
    t, p = ttree(leaves), '{==}'
    for j in range(lo, d):
        r = f'F.array__trep(U32, {j}n, 0)' if zero else f'{c}{j}'
        pr = f'F.array__trep_perfect(U32, {j}n, 0)' if zero else f'p{c}{j}'
        p = f'F.logic__and_intro(F.array__perfect(U32, {j}n, {t}), F.array__perfect(U32, {j}n, {r}), {p}, {pr})'
        t = f'F.TNode{{{t}, {r}}}'
    params = '' if zero else (', '.join(f'+{c}{j}: {TV}' for j in range(lo, d)) + ', ' + ', '.join(f'+p{c}{j}: {pf(j, f"{c}{j}")}' for j in range(lo, d)))
    return t, p, params


def sync_committee(name='SyncCommittee'):
    """Vector[BLSPubkey, 512] (6144 words = 2^12 + 2^11) then a Bytes48, 24624 bytes;
    buffer depth 13 = [A | B | C], A of depth 12 (its first word literal), B of
    depth 11, C of depth 11 whose first 16 words are literal (the Bytes48 and 4
    padding words), the rest free."""
    n, nw, pkb, pkw = 24624, 6156, 24576, 6144
    R = f'T.{name}'
    L = list(HEAD) + ['import ./arr_enc.bend as AN', '', '# GENERATED by codegen/spec_laws.py (spec_arr.sync_committee). Do not edit.',
                      f'# {name}: Vector[BLSPubkey, 512] (array-backed, {pkw} words) and a Bytes48.', '']
    w = L.append
    g = [f'g{i}' for i in range(12)]
    G = '[' + ', '.join(g) + ']'
    B48 = f'T.Bytes48{{{", ".join(g)}}}'
    gsig = ', '.join(f'+{x}: U32' for x in g)
    # decode input
    SA, pSA, sparams = spine(12, 'x0', 'q')
    SC, pSC, cparams = head_chunk(11, 4, g + ['z0', 'z1', 'z2', 'z3'], 'c')
    TIN = f'F.TNode{{{SA}, F.TNode{{bb, {SC}}}}}'
    pTIN = (f'F.logic__and_intro(F.array__perfect(U32, 12n, {SA}), F.array__perfect(U32, 12n, F.TNode{{bb, {SC}}}), {pSA}, '
            f'F.logic__and_intro(F.array__perfect(U32, 11n, bb), F.array__perfect(U32, 11n, {SC}), pbb, {pSC}))')
    iparams = f'{sparams}, +bb: {TV}, +pbb: {pf(11, "bb")}, {gsig}, +z0: U32, +z1: U32, +z2: U32, +z3: U32, {cparams}'
    iargs = ', '.join(['x0'] + [f'q{j}' for j in range(12)] + [f'pq{j}' for j in range(12)] + ['bb', 'pbb'] + g + ['z0', 'z1', 'z2', 'z3']
                      + [f'c{j}' for j in range(4, 11)] + [f'pc{j}' for j in range(4, 11)])
    BUF = f'B.Buf{{{th(TIN)}, {n}}}'
    PK = f'O.Words{{ANode{{{th(SA)}, ANode{{{th("bb")}, Array.new(U32, 11n, 0)}}}}, {pkb}}}'
    OBJ = f'{R}{{{PK}, {B48}}}'
    RT = f'B.Buf & Maybe<&1, {R}>'
    W = f'F.spec_common__append(U32, {slots(SA)}, {slots("bb")})'
    BY = f'SF.limbs(F.spec_common__append(U32, {slots(SA)}, F.spec_common__append(U32, {slots("bb")}, {G})))'
    w(f'# decoding any buffer of {n} bytes accepts: the pubkeys are the first {pkw} words, the')
    w(f'# aggregate pubkey the next 12 (every perfect tree of depth 13 is such a tree)')
    w(f'def {name}_spec_decode({iparams})')
    w(f'    -> {{T.{name}_decode({BUF}, {n}) == ({BUF}, Some{{{OBJ}}}) : {RT}}}:')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({pkw}, 0, 0, Array.new(U32, 13n, 0), {th(TIN)}),')
    w(f'      (ANode{{{th(SA)}, ANode{{{th("bb")}, Array.new(U32, 11n, 0)}}}}, {th(TIN)}),')
    w(f'      AC.sc3(11n, {pkw}, 0, 0, {SA}, bb, {SC}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {pSA}, pbb, {pSC})) :')
    w(f'    {{T.{name}_some(T.{name}_rd0(0, {n}, O.ci_fin({n}, {pkb}, _))) == ({BUF}, Some{{{OBJ}}}) : {RT}}}')
    w('  {==}')
    w('')
    # the loader's buffer of the bytes of those words: [A | [B | the aggregate, then zeros]]
    WI = f'F.spec_common__append(U32, {slots(SA)}, F.spec_common__append(U32, {slots("bb")}, {G}))'
    ZC, pZC, _ = head_chunk(11, 4, g + ['0', '0', '0', '0'], None, zero=True)
    BUFZ = f'B.Buf{{{th(f"F.TNode{{{SA}, F.TNode{{bb, {ZC}}}}}")}, {n}}}'
    D13 = 'F.array__trep(U32, 13n, 0)'
    TB = f'F.spec_common__append(U32, {slots("bb")}, {G})'
    C2 = f'Nat.add(F.spec_common__pow2(11n), 12n)'
    C1 = f'Nat.add(F.spec_common__pow2(12n), {C2})'
    eB = (f'Equal.trans(Nat, F.spec_common__length(U32, {TB}), Nat.add(F.spec_common__length(U32, {slots("bb")}), 12n), {C2}, '
          f'F.list__length_append(U32, {slots("bb")}, {G}), Equal.cong(Nat, Nat, z => Nat.add(z, 12n), F.spec_common__length(U32, {slots("bb")}), F.spec_common__pow2(11n), F.array__slots_length(U32, 11n, bb, pbb)))')
    eL = (f'Equal.trans(Nat, F.spec_common__length(U32, {WI}), Nat.add(F.spec_common__length(U32, {slots(SA)}), F.spec_common__length(U32, {TB})), {C1}, '
          f'F.list__length_append(U32, {slots(SA)}, {TB}), '
          f'Equal.trans(Nat, Nat.add(F.spec_common__length(U32, {slots(SA)}), F.spec_common__length(U32, {TB})), Nat.add(F.spec_common__pow2(12n), F.spec_common__length(U32, {TB})), {C1}, '
          f'Equal.cong(Nat, Nat, z => Nat.add(z, F.spec_common__length(U32, {TB})), F.spec_common__length(U32, {slots(SA)}), F.spec_common__pow2(12n), F.array__slots_length(U32, 12n, {SA}, {pSA})), '
          f'Equal.cong(Nat, Nat, z => Nat.add(F.spec_common__pow2(12n), z), F.spec_common__length(U32, {TB}), {C2}, {eB})))')
    hfill = (f'F.logic__subst(Nat, z => {{Nat.is_le(Nat.add(z, 0n), F.spec_common__pow2(13n)) == True{{}} : Bool}}, {C1}, '
             f'F.spec_common__length(U32, {WI}), Equal.sym(Nat, F.spec_common__length(U32, {WI}), {C1}, {eL}), {{==}})')
    zparams = f'{sparams}, +bb: {TV}, +pbb: {pf(11, "bb")}, {gsig}'
    w(f'# the buffer the loader builds from the bytes of the pubkeys\' words and the aggregate\'s')
    w(f'def {name}_spec_load({zparams})')
    w(f'    -> {{B.fill_at(B.alloc({n}), 0, SF.limbs({WI})) == {BUFZ} : B.Buf}}:')
    w(f'  %Equal.sym(Nat, B.capacity({n}), 13n, {{==}}) : {{B.Buf{{B.fill_go(SF.limbs({WI}), Array.new(U32, _, 0), U32.shrn(0, 2n)), {n}}} == {BUFZ} : B.Buf}}')
    w(f'  %Equal.sym(Array<U32>, Array.new(U32, 13n, 0), {th(D13)}, F.array__new(U32, 13n, 0)) : {{B.Buf{{B.fill_go(SF.limbs({WI}), _, U32.shrn(0, 2n)), {n}}} == {BUFZ} : B.Buf}}')
    w(f'  %Equal.sym(Array<U32>, B.fill_go(SF.limbs({WI}), {th(D13)}, U32.shrn(0, 2n)), {th(f"AC.cpt(13n, F.spec_common__length(U32, {WI}), 0n, 0n, {D13}, {WI})")}, '
      f'AE.fill({WI}, 13n, {D13}, U32.shrn(0, 2n), 0n, {{==}}, {{==}}, {hfill}, F.array__trep_perfect(U32, 13n, 0))) :')
    w(f'    {{B.Buf{{_, {n}}} == {BUFZ} : B.Buf}}')
    w(f'  %Equal.sym(Nat, F.spec_common__length(U32, {WI}), {C1}, {eL}) :')
    w(f'    {{B.Buf{{{th(f"AC.cpt(13n, _, 0n, 0n, {D13}, {WI})")}, {n}}} == {BUFZ} : B.Buf}}')
    w(f'  %Equal.sym(F.array__Tree<U32>, AC.cpt(13n, {C1}, 0n, 0n, {D13}, {WI}), F.TNode{{{SA}, AC.cpt(12n, {C2}, 0n, 0n, F.array__trep(U32, 12n, 0), {TB})}}, AN.cpt_tail_q(12n, 13n, {{==}}, {C2}, {SA}, {TB}, {pSA})) :')
    w(f'    {{B.Buf{{{th("_")}, {n}}} == {BUFZ} : B.Buf}}')
    w(f'  %Equal.sym(F.array__Tree<U32>, AC.cpt(12n, {C2}, 0n, 0n, F.array__trep(U32, 12n, 0), {TB}), F.TNode{{bb, AC.cpt(11n, 12n, 0n, 0n, F.array__trep(U32, 11n, 0), {G})}}, AN.cpt_tail_q(11n, 12n, {{==}}, 12n, bb, {G}, pbb)) :')
    w(f'    {{B.Buf{{{th(f"F.TNode{{{SA}, _}}")}, {n}}} == {BUFZ} : B.Buf}}')
    w('  {==}')
    w('')
    zargs = ', '.join(['x0'] + [f'q{j}' for j in range(12)] + [f'pq{j}' for j in range(12)] + ['bb', 'pbb'] + g + ['0', '0', '0', '0']
                      + [f'F.array__trep(U32, {j}n, 0)' for j in range(4, 11)] + [f'F.array__trep_perfect(U32, {j}n, 0)' for j in range(4, 11)])
    OBJZ = f'{R}{{O.Words{{ANode{{{th(SA)}, ANode{{{th("bb")}, Array.new(U32, 11n, 0)}}}}, {pkb}}}, {B48}}}'
    w(f'# decoding the buffer the loader builds from those bytes')
    w(f'def {name}_spec_input({zparams})')
    w(f'    -> {{T.{name}_decode(B.fill_at(B.alloc({n}), 0, SF.limbs({WI})), {n}) == ({BUFZ}, Some{{{OBJZ}}}) : {RT}}}:')
    w(f'  %Equal.sym(B.Buf, B.fill_at(B.alloc({n}), 0, SF.limbs({WI})), {BUFZ}, {name}_spec_load({", ".join(["x0"] + [f"q{j}" for j in range(12)] + [f"pq{j}" for j in range(12)] + ["bb", "pbb"] + g)})) :')
    w(f'    {{T.{name}_decode(_, {n}) == ({BUFZ}, Some{{{OBJZ}}}) : {RT}}}')
    w(f'  {name}_spec_decode({zargs})')
    w('')
    # take of the emitted words -> the layout words
    def take_eq(T, sA, sB, sC_, pA_, pB_, G_):
        """{take(slots T, 1+6155) == append(sA, append(sB, G))} for T = [A | B | C]."""
        return (f'AS.take3({sA}, {sB}, {sC_}, 4096n, 2048n, {nw - 1}n, 12n, AS.len_tree(12n, {pA_[0]}, 4096n, {pA_[1]}, {{==}}), '
                f'AS.len_tree(11n, {pB_[0]}, 2048n, {pB_[1]}, {{==}}), {{==}}, {{==}}, {{==}})')
    RHSV = f'({BUF}, {BY})'
    w(f'# the bytes of that buffer: the pubkeys\' words, then the aggregate pubkey\'s')
    w(f'def {name}_spec_view({iparams})')
    w(f'    -> {{B.emit({BUF}, 0, {nw}) == {RHSV} : B.Buf & +List<U32>}}:')
    w(f'  %{take_eq(TIN, slots(SA), slots("bb"), slots(SC), (SA, pSA), ("bb", "pbb"), G)} :')
    w(f'    {{B.emit({BUF}, 0, {nw}) == ({BUF}, SF.limbs(_)) : B.Buf & +List<U32>}}')
    w(f'  AE.emit_take(13n, {TIN}, {n}, {nw}, {nw - 1}n, {{==}}, {{==}}, {{==}}, {{==}}, {pTIN})')
    w('')
    # encoder
    SE, pSE, separams = spine(12, 'y0', 'r')
    ST = f'F.TNode{{{SE}, F.TNode{{bb, rr}}}}'
    pST = (f'F.logic__and_intro(F.array__perfect(U32, 12n, {SE}), F.array__perfect(U32, 12n, F.TNode{{bb, rr}}), {pSE}, '
           f'F.logic__and_intro(F.array__perfect(U32, 11n, bb), F.array__perfect(U32, 11n, rr), pbb, prr))')
    eparams = f'{separams}, +bb: {TV}, +pbb: {pf(11, "bb")}, +rr: {TV}, +prr: {pf(11, "rr")}, {gsig}'
    PKE = f'O.Words{{{th(ST)}, {pkb}}}'
    OBJE = f'{R}{{{PKE}, {B48}}}'
    ZT, pZT, _ = head_chunk(11, 4, g + ['0', '0', '0', '0'], None, zero=True)
    TOUT = f'F.TNode{{{SE}, F.TNode{{bb, {ZT}}}}}'
    pTOUT = (f'F.logic__and_intro(F.array__perfect(U32, 12n, {SE}), F.array__perfect(U32, 12n, F.TNode{{bb, {ZT}}}), {pSE}, '
             f'F.logic__and_intro(F.array__perfect(U32, 11n, bb), F.array__perfect(U32, 11n, {ZT}), pbb, {pZT}))')
    BYE = f'SF.limbs(F.spec_common__append(U32, {slots(SE)}, F.spec_common__append(U32, {slots("bb")}, {G})))'
    BRHS = f'({OBJE}, {BYE})'
    TY = f'{R} & +List<U32>'
    ctx = lambda inner: f'{{SF.emitted({R}, T.{name}_enc_out(T.{name}_put_drop({inner})), {nw}) == {BRHS} : {TY}}}'
    A1 = f'ANode{{{th(SE)}, ANode{{{th("bb")}, Array.new(U32, 11n, 0)}}}}'
    w(f'# the encoder emits the pubkeys\' words (storage [A | B | R], R free) then the aggregate\'s')
    w(f'def {name}_spec_bytes({eparams})')
    w(f'    -> {{SF.emitted({R}, T.{name}_encode({OBJE}), {nw}) == {BRHS} : {TY}}}:')
    w(f'  %Equal.sym(O.Words & Bool, O.words_ok({PKE}, {pkb}, {pkb}, False{{}}, 48), ({PKE}, True{{}}), AC.vok(13n, {ST}, {pkb}, {pkb}, {pkb}, False{{}}, 48, {{==}}, {{==}}, {{==}}, {{==}}, {pST})) :')
    w('    ' + ctx(f'T.{name}_pw0(0, 0, {B48}, T.v512_b48_pk(Array.new(U32, 13n, 0), (0 + 0 : U32), _))'))
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({pkw}, 0, 0, Array.new(U32, 13n, 0), {th(ST)}), ({A1}, {th(ST)}),')
    w(f'      AC.sc3(11n, {pkw}, 0, 0, {SE}, bb, rr, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {pSE}, pbb, prr)) :')
    w('    ' + ctx(f'T.{name}_pw0(0, 0, {B48}, T.v512_b48_pk_ok(O.put_fin({pkb}, _)))'))
    w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit(B.Buf{{{th(TOUT)}, {n}}}, 0, {nw}), (B.Buf{{{th(TOUT)}, {n}}}, SF.limbs(F.spec_common__take(U32, {slots(TOUT)}, 1n+{nw - 1}n))),')
    w(f'      AE.emit_take(13n, {TOUT}, {n}, {nw}, {nw - 1}n, {{==}}, {{==}}, {{==}}, {{==}}, {pTOUT})) :')
    w(f'    {{({OBJE}, SF.listed(_)) == {BRHS} : {TY}}}')
    w(f'  %Equal.sym(List<&2, U32>, F.spec_common__take(U32, {slots(TOUT)}, 1n+{nw - 1}n), F.spec_common__append(U32, {slots(SE)}, F.spec_common__append(U32, {slots("bb")}, {G})),')
    w(f'      {take_eq(TOUT, slots(SE), slots("bb"), slots(ZT), (SE, pSE), ("bb", "pbb"), G)}) :')
    w(f'    {{({OBJE}, SF.limbs(_)) == {BRHS} : {TY}}}')
    w('  {==}')
    w('')
    # spec side, over the pubkeys' words as any A (depth 12) and B (depth 11)
    spec = f'Spec.{name}()'
    WA = f'F.spec_common__append(U32, {slots("a")}, {slots("b")})'
    VAL = f'S.Sequence{{S.Items{{S.Sequence{{AV.ch12({WA})}}, S.Items{{S.BytesValue{{SF.limbs({G})}}, S.EmptyItems{{}}}}}}}}'
    BYS = f'SF.limbs(F.spec_common__append(U32, {slots("a")}, F.spec_common__append(U32, {slots("b")}, {G})))'
    PT = 'Maybe<&2, +List<S.Part>>'
    FL = f'SF.flat([{WA}, {G}])'
    RHSF = f'Some{{[S.Fixed{{{FL}}}]}}'
    hdr = f'+a: {TV}, +b: {TV}, +pa: {pf(12, "a")}, +pb: {pf(11, "b")}, {gsig}, +s: S.Schema, +es: {{s == {spec} : S.Schema}}'
    args = 'a, b, pa, pb, ' + ', '.join(g) + ', s, es'
    fs = 'SH.Container_fields(s)'
    h1 = f'SH.Chain_head({fs})'
    t1 = f'SH.Chain_tail({fs})'
    h2 = f'SH.Chain_head({t1})'
    t2 = f'SH.Chain_tail({t1})'
    BV = 'S.ByteVector{48n}'
    V1 = f'S.Vector{{{BV}, SH.Vector_length({h1})}}'
    names = 'SH.Container_names(s)'
    gg = lambda sch, rhs: f'{{Codec.parts({VAL}, {sch}) == {rhs} : {PT}}}'
    la, lb, lg = f'SF.limbs({slots("a")})', f'SF.limbs({slots("b")})', f'SF.limbs({G})'
    w(f'# the spec\'s parts of the value (pubkeys: the words of a, then b; aggregate: g) at the schema')
    w(f'def {name}_spec_parts({hdr})')
    w(f'    -> {{Codec.parts({VAL}, s) == Some{{[S.Fixed{{{BYS}}}]}} : {PT}}}:')
    w(f'  %Equal.sym(+List<U32>, SF.limbs(F.spec_common__append(U32, {slots("a")}, F.spec_common__append(U32, {slots("b")}, {G}))), List.append(&2, U32, {la}, SF.limbs(F.spec_common__append(U32, {slots("b")}, {G}))), AS.limbs_app({slots("a")}, F.spec_common__append(U32, {slots("b")}, {G}))) :')
    w('    ' + gg('s', 'Some{[S.Fixed{_}]}'))
    w(f'  %Equal.sym(+List<U32>, SF.limbs(F.spec_common__append(U32, {slots("b")}, {G})), List.append(&2, U32, {lb}, {lg}), AS.limbs_app({slots("b")}, {G})) :')
    w('    ' + gg('s', f'Some{{[S.Fixed{{List.append(&2, U32, {la}, _)}}]}}'))
    w(f'  %AS.lapp_assoc({la}, {lb}, {lg}) :')
    w('    ' + gg('s', 'Some{[S.Fixed{_}]}'))
    w(f'  %AS.limbs_app({slots("a")}, {slots("b")}) :')
    w('    ' + gg('s', f'Some{{[S.Fixed{{List.append(&2, U32, _, {lg})}}]}}'))
    w(f'  %AS.app_nil({lg}) :')
    w('    ' + gg('s', f'Some{{[S.Fixed{{List.append(&2, U32, SF.limbs({WA}), _)}}]}}'))
    steps = [
        (f'Equal.sym(S.Schema, s, S.Container{{{names}, {fs}}}, SH.Container_shape(s, {bfact(spec, "SH.is_Container(s)")}))', '_'),
        (f'Equal.sym(S.Schema, {fs}, S.Chain{{{h1}, {t1}}}, SH.Chain_shape({fs}, {bfact(spec, f"SH.is_Chain({fs})")}))', f'S.Container{{{names}, _}}'),
        (f'Equal.sym(S.Schema, {t1}, S.Chain{{{h2}, {t2}}}, SH.Chain_shape({t1}, {bfact(spec, f"SH.is_Chain({t1})")}))', f'S.Container{{{names}, S.Chain{{{h1}, _}}}}'),
        (f'Equal.sym(S.Schema, {t2}, S.End{{}}, SH.End_shape({t2}, {bfact(spec, f"SH.is_End({t2})")}))', f'S.Container{{{names}, S.Chain{{{h1}, S.Chain{{{h2}, _}}}}}}'),
        (f'Equal.sym(S.Schema, {h1}, S.Vector{{SH.Vector_element({h1}), SH.Vector_length({h1})}}, SH.Vector_shape({h1}, {bfact(spec, f"SH.is_Vector({h1})")}))', f'S.Container{{{names}, S.Chain{{_, S.Chain{{{h2}, S.End{{}}}}}}}}'),
        (f'Equal.sym(S.Schema, SH.Vector_element({h1}), {BV}, {sfact(spec, f"SH.Vector_element({h1})", BV)})', f'S.Container{{{names}, S.Chain{{S.Vector{{_, SH.Vector_length({h1})}}, S.Chain{{{h2}, S.End{{}}}}}}}}'),
        (f'Equal.sym(S.Schema, {h2}, {BV}, {sfact(spec, h2, BV)})', f'S.Container{{{names}, S.Chain{{{V1}, S.Chain{{_, S.End{{}}}}}}}}'),
    ]
    for eq, sch in steps:
        w(f'  %{eq} :')
        w('    ' + gg(sch, RHSF))
    FIELDS = f'S.Chain{{{V1}, S.Chain{{{BV}, S.End{{}}}}}}'
    agg = lambda a_, b_: f'{{Codec.aggregate(Codec.concatenate({a_}, Codec.concatenate({b_}, Some{{[]}})), SSC.fixed_size({FIELDS})) == {RHSF} : {PT}}}'
    hl = (f'AS.len2({slots("a")}, {slots("b")}, 4096n, 2048n, {pkw}n, AS.len_tree(12n, a, 4096n, pa, {{==}}), '
          f'AS.len_tree(11n, b, 2048n, pb, {{==}}), {{==}})')
    kf = bfact(spec, f'Nat.is_eq(SH.Vector_length({h1}), 512n)')
    vp = (f'AV.vparts12({V1}, {WA}, 512n, {pkw}n, {pkb}n, {{==}}, {{==}}, {kf}, {{==}}, {hl}, {{==}}, '
          f'AS.wlen_len({WA}, {pkw}n, {pkb}n, {hl}, {{==}}), {{==}})')
    P1 = f'Codec.parts(S.Sequence{{AV.ch12({WA})}}, {V1})'
    P2 = f'Codec.parts(S.BytesValue{{{lg}}}, {BV})'
    F1 = f'Some{{[S.Fixed{{SF.limbs({WA})}}]}}'
    F2 = f'Some{{[S.Fixed{{{lg}}}]}}'
    w(f'  %Equal.sym({PT}, {P1}, {F1}, {vp}) :')
    w('    ' + agg('_', P2))
    w(f'  %Equal.sym({PT}, {P2}, {F2}, SF.bytes_part(g0, [{", ".join(g[1:])}], {{==}})) :')
    w('    ' + agg(F1, '_'))
    x = f'Nat.add(Nat.mul(SH.Vector_length({h1}), 48n), Nat.add(48n, 0n))'
    ea = (f'Equal.trans(Nat, List.length(&2, U32, SF.limbs({WA})), SF.wlen({WA}), {pkb}n, AS.len_limbs({WA}), '
          f'AS.wlen_len({WA}, {pkw}n, {pkb}n, {hl}, {{==}}))')
    w(f'  AS.agg([{WA}, {G}], {x}, {n}n,')
    w(f'    AS.add2(List.length(&2, U32, SF.limbs({WA})), List.length(&2, U32, {lg}), {pkb}n, 48n, {n}n, {ea}, {{==}}, {{==}}), {{==}})')
    w('')
    w(f'# encoder soundness against spec/codec.bend')
    w(f'def {name}_spec_encode({hdr})')
    w(f'    -> Decoding.decodes(s, {BYS}, {VAL}):')
    w(f'  SF.encoding_of_parts(s, {VAL}, {BYS}, {name}_spec_parts({args}))')
    w('')
    reject(w, name, n, name, R)
    U = []
    unique(U.append, name, hdr, args, BYS, VAL)
    return '\n'.join(L) + '\n', U


def chainw(proof):
    """A walk() proof of a fixed field (SF.cat_fixed chains, SF.aggregate_fixed containers) in the exact
    forms of its parts terms: var_laws' chainify (VS.chain_fixed) and seqwrap (VSQ.seq_parts), spelled
    with this module's aliases. The cat_fixed form met the enclosing parts only by evaluating them
    (BlobSidecar_spec_parts: 4.6 s on the SignedBeaconBlockHeader field)."""
    import re as _re
    import var_laws as VL
    t = _re.sub(r'(?<![\w.])SF\.(cat_fixed|aggregate_fixed)\(', r'F.\1(', proof)
    t = VL.seqwrap(VL.chainify(t))
    t = _re.sub(r'(?<![\w.])F\.flat\(', 'SF.flat(', t)
    t = _re.sub(r'(?<![\w.])F\.aggregate_fixed\(', 'SF.aggregate_fixed(', t)
    t = _re.sub(r'(?<![\w.])FD\.logic__subst\(', 'F.logic__subst(', t)
    return _re.sub(r'(?<![\w.])SC\.fixed_size\(', 'SSC.fixed_size(', t)


def blob_sidecar(name='BlobSidecar'):
    """index (2 words), blob (2^15 words at word 2: not aligned to the buffer's
    subtrees), kzg_commitment, kzg_proof (12 words each), signed_block_header (52
    words), kzg_commitment_inclusion_proof (136 words), 131928 bytes; buffer depth 16.

    Decoder, view, spec, encoder and uniqueness laws. The buffer is every perfect tree of
    depth 16 written [[x0, x1 | M1 | .. | M14] | [G | P8 | .. | P14]] with the
    first two words and the 256-word head G of the right half literal (so the
    field reads compute) and M_j, P_j free trees of depth j. The blob's storage is
    the canonical tree of the 2^15 words after the first two (arr_shift `bq`).
    Encoder bytes: the output after the blob copy is [sp(14) | rp(14)]
    (arr_enc.enc_copy), the field writes compute on it, and the emitted words are
    split at the halves (arr_enc.emit_split) so the right half's zeros are never
    listed.
    """
    import re
    import spec_laws as SL
    import generate as G
    import schema as SCH
    from pathlib import Path
    names = SCH.load(Path(__file__).resolve().parents[1] / 'codegen/fulu.yaml')
    g = G.Gen()
    for n_, t_ in names.items():
        g.shape(t_)
    t = names[name]
    n, nw = 131928, 32982
    R = f'T.{name}'
    # the small fields, walked; their words renamed f0 .. f211 in layout order
    fields = [(f, ft) for f, ft in t.fields]
    base = 0
    small = {}
    for f, ft in fields:
        if f in ('index', 'blob'):
            continue
        nd = SL.walk(g, ft, iter(range(10000, 20000)))
        k = len(nd.words)
        ren = lambda s_, b=base: re.sub(r'\bx(1\d{4})\b', lambda m: f'f{int(m.group(1)) - 10000 + b}', s_)
        sf = lambda s_: re.sub(r'\bF\.', 'SF.', s_)
        pads = {q: f'g{i}' for i, q in enumerate(nd.opads)}
        assert not pads or f == 'kzg_commitment_inclusion_proof', f
        renq = lambda s_: re.sub(r'\bq1\d{4}\b', lambda m: pads[m.group(0)], s_)
        small[f] = dict(obj=ren(nd.dec), objf=renq(ren(nd.obj)), pads=[pads[q] for q in nd.opads],
                        val=sf(ren(nd.val)), sch=nd.sch, proof=sf(ren(nd.proof)), words=[ren(x) for x in nd.words])
        base += k
    assert base == 212, base
    FS = [f'f{i}' for i in range(212)]
    FSL = '[' + ', '.join(FS) + ']'
    L = list(HEAD) + ['import ./arr_shift.bend as AH', 'import ./arr_enc.bend as AN', 'import ./vseq.bend as VSQ', 'import ./vspec.bend as VS', '', '# GENERATED by codegen/spec_laws.py (spec_arr.blob_sidecar). Do not edit.',
                      f'# {name}: the blob is 2^15 words at word 2 of the buffer, array-backed.', '']
    w = L.append
    # the buffer skeleton
    Lt, pL = 'F.TNode{F.TLeaf{x0}, F.TLeaf{x1}}', '{==}'
    for j in range(1, 15):
        pL = f'F.logic__and_intro(F.array__perfect(U32, {j}n, {Lt}), F.array__perfect(U32, {j}n, m{j}), {pL}, pm{j})'
        Lt = f'F.TNode{{{Lt}, m{j}}}'
    Gl = ['t0', 't1'] + FS + [f'z{i}' for i in range(42)]
    Rt, pR = ttree(Gl), '{==}'
    for j in range(8, 15):
        pR = f'F.logic__and_intro(F.array__perfect(U32, {j}n, {Rt}), F.array__perfect(U32, {j}n, p{j}), {pR}, pp{j})'
        Rt = f'F.TNode{{{Rt}, p{j}}}'
    I = f'F.TNode{{{Lt}, {Rt}}}'
    pI = f'F.logic__and_intro(F.array__perfect(U32, 15n, {Lt}), F.array__perfect(U32, 15n, {Rt}), {pL}, {pR})'
    params = ('+x0: U32, +x1: U32, ' + ', '.join(f'+m{j}: {TV}' for j in range(1, 15)) + ', '
              + ', '.join(f'+pm{j}: {pf(j, f"m{j}")}' for j in range(1, 15)) + ', +t0: U32, +t1: U32, '
              + ', '.join(f'+{x}: U32' for x in FS) + ', ' + ', '.join(f'+z{i}: U32' for i in range(42)) + ', '
              + ', '.join(f'+p{j}: {TV}' for j in range(8, 15)) + ', ' + ', '.join(f'+pp{j}: {pf(j, f"p{j}")}' for j in range(8, 15)))
    BUF = f'B.Buf{{{th(I)}, {n}}}'
    SI = slots(I)
    BW = f'AH.tk(AH.dp({SI}, 2n), 32768n)'
    BQ = f'AH.bq(15n, {BW}, m1)'
    fo = [small[f] for f, _ in fields if f not in ('index', 'blob')]
    OBJ = (f'{R}{{O.U64{{x0, x1}}, O.Words{{ANode{{{th(BQ)}, Array.new(U32, 15n, 0)}}, 131072}}, '
           f'{fo[0]["obj"]}, {fo[1]["obj"]}, O.BSome{{{fo[2]["obj"]}, O.BNone{{}}}}, {fo[3]["obj"]}}}')
    RT = f'B.Buf & Maybe<&1, {R}>'
    w(f'# decoding any buffer of {n} bytes accepts: the index is words 0, 1, the blob\'s storage')
    w(f'# the canonical tree of words 2 .. 32769, the other fields the words that follow')
    w(f'def {name}_spec_decode({params})')
    w(f'    -> {{T.{name}_decode({BUF}, {n}) == ({BUF}, Some{{{OBJ}}}) : {RT}}}:')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy(32768, 2, 0, Array.new(U32, 16n, 0), {th(I)}), (ANode{{{th(BQ)}, Array.new(U32, 15n, 0)}}, {th(I)}),')
    w(f'      AH.zlo(15n, 16n, 32768, 2, 0, 2n, 32768n, {I}, m1, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {pI})) :')
    w(f'    {{T.{name}_some(T.{name}_rd1(0, {n}, O.U64{{x0, x1}}, O.ci_fin({n}, 131072, _))) == ({BUF}, Some{{{OBJ}}}) : {RT}}}')
    w('  {==}')
    w('')
    # the loader: the input bytes are the words of the left half [x0, x1 | M1 .. M14]
    # (so the blob is the words after the first two, whatever they are) then the last
    # two blob words and the field words; the loaded buffer's right half is those
    # words then zeros (arr_enc.cpt_tail)
    RL = '[t0, t1, ' + ', '.join(FS) + ']'
    WI = f'F.spec_common__append(U32, {slots(Lt)}, {RL})'
    RZ = ttree(['t0', 't1'] + FS + ['0'] * 42)
    for j in range(8, 15):
        RZ = f'F.TNode{{{RZ}, F.array__trep(U32, {j}n, 0)}}'
    IZ = f'F.TNode{{{Lt}, {RZ}}}'
    BUFZ = f'B.Buf{{{th(IZ)}, {n}}}'
    zparams = ('+x0: U32, +x1: U32, ' + ', '.join(f'+m{j}: {TV}' for j in range(1, 15)) + ', '
               + ', '.join(f'+pm{j}: {pf(j, f"m{j}")}' for j in range(1, 15)) + ', +t0: U32, +t1: U32, '
               + ', '.join(f'+{x}: U32' for x in FS))
    zargs = ', '.join(['x0', 'x1'] + [f'm{j}' for j in range(1, 15)] + [f'pm{j}' for j in range(1, 15)] + ['t0', 't1'] + FS)
    w(f'# the buffer the loader builds from the bytes of the words of [x0, x1 | M1 .. M14], then')
    w(f'# the blob\'s last two words and the field words')
    w(f'def {name}_spec_load({zparams})')
    w(f'    -> {{B.fill_at(B.alloc({n}), 0, SF.limbs({WI})) == {BUFZ} : B.Buf}}:')
    w(f'  AN.load_tail(15n, 214n, {n}, {Lt}, {RL}, {pL}, {{==}}, {{==}}, {{==}}, {{==}})')
    w('')
    # the input law keeps the zero subtrees of the right half as trees p_j equal to zero
    # trees: with them literal, the blob storage's word list (its slots) would unfold them
    RP = ttree(['t0', 't1'] + FS + ['0'] * 42)
    for j in range(8, 15):
        RP = f'F.TNode{{{RP}, p{j}}}'
    IP = f'F.TNode{{{Lt}, {RP}}}'
    BUFP = f'B.Buf{{{th(IP)}, {n}}}'
    pparams = zparams + ', ' + ', '.join(f'+p{j}: {TV}' for j in range(8, 15)) + ', ' + ', '.join(f'+hp{j}: {{p{j} == F.array__trep(U32, {j}n, 0) : {TV}}}' for j in range(8, 15))
    pargs = zargs + ', ' + ', '.join(f'p{j}' for j in range(8, 15)) + ', ' + ', '.join(f'hp{j}' for j in range(8, 15))
    w(f'def {name}_spec_load_p({pparams})')
    w(f'    -> {{B.fill_at(B.alloc({n}), 0, SF.limbs({WI})) == {BUFP} : B.Buf}}:')
    cur = RP
    done = RP
    for j in range(14, 7, -1):
        mot = done.replace(f', p{j}}}', ', _}')
        w(f'  %Equal.sym({TV}, p{j}, F.array__trep(U32, {j}n, 0), hp{j}) : {{B.fill_at(B.alloc({n}), 0, SF.limbs({WI})) == B.Buf{{{th(f"F.TNode{{{Lt}, {mot}}}")}, {n}}} : B.Buf}}')
        done = done.replace(f', p{j}}}', f', F.array__trep(U32, {j}n, 0)}}')
    w(f'  {name}_spec_load({zargs})')
    w('')
    ppf = lambda j: f'F.logic__subst({TV}, z => {{F.array__perfect(U32, {j}n, z) == True{{}} : Bool}}, F.array__trep(U32, {j}n, 0), p{j}, Equal.sym({TV}, p{j}, F.array__trep(U32, {j}n, 0), hp{j}), F.array__trep_perfect(U32, {j}n, 0))'
    decargs = ', '.join(['x0', 'x1'] + [f'm{j}' for j in range(1, 15)] + [f'pm{j}' for j in range(1, 15)] + ['t0', 't1'] + FS + ['0'] * 42
                        + [f'p{j}' for j in range(8, 15)] + [ppf(j) for j in range(8, 15)])
    OBJP = OBJ.replace(I, IP)
    w(f'# decoding the buffer the loader builds from those bytes (p_j: the zero subtrees)')
    w(f'def {name}_spec_input({pparams})')
    w(f'    -> {{T.{name}_decode(B.fill_at(B.alloc({n}), 0, SF.limbs({WI})), {n}) == ({BUFP}, Some{{{OBJP}}}) : {RT}}}:')
    w(f'  %Equal.sym(B.Buf, B.fill_at(B.alloc({n}), 0, SF.limbs({WI})), {BUFP}, {name}_spec_load_p({pargs})) :')
    w(f'    {{T.{name}_decode(_, {n}) == ({BUFP}, Some{{{OBJP}}}) : {RT}}}')
    w(f'  {name}_spec_decode({decargs})')
    w('')
    BY = lambda bw: f'SF.limbs(F.spec_common__append(U32, [x0, x1], F.spec_common__append(U32, {bw}, {FSL})))'
    SL_, SR_ = slots(Lt), slots(Rt)
    TKR = f'AH.tk(AH.dp({SR_}, 2n), 212n)'
    w(f'# the bytes of that buffer: the index, the blob\'s words, then the other fields\' words')
    w(f'def {name}_spec_view({params}, +k: U32, +ek: {{k == {nw} : U32}})')
    w(f'    -> {{B.emit({BUF}, 0, k) == ({BUF}, {BY(BW)}) : B.Buf & +List<U32>}}:')
    ctx = lambda inner: f'{{B.emit({BUF}, 0, k) == ({BUF}, SF.limbs(F.spec_common__append(U32, [x0, x1], {inner}))) : B.Buf & +List<U32>}}'
    w(f'  %Equal.sym(List<&2, U32>, {FSL}, {TKR}, {{==}}) :')
    w('    ' + ctx(f'F.spec_common__append(U32, {BW}, _)'))
    w(f'  %AH.drop_app_lit({SL_}, {SR_}, 32770n, 32768n, 2n, AS.len_tree(15n, {Lt}, 32768n, {pL}, {{==}}), {{==}}, {{==}}) :')
    w('    ' + ctx(f'F.spec_common__append(U32, {BW}, AH.tk(_, 212n))'))
    w(f'  %AH.drop_drop_lit({SI}, 2n, 32768n, 32770n, {{==}}) :')
    w('    ' + ctx(f'F.spec_common__append(U32, {BW}, AH.tk(_, 212n))'))
    w(f'  %AH.take_split_lit(AH.dp({SI}, 2n), 32980n, 32768n, 212n, {{==}}, {{==}}) :')
    w('    ' + ctx('_'))
    ctx2 = lambda inner: f'{{B.emit({BUF}, 0, k) == ({BUF}, SF.limbs(F.spec_common__append(U32, {inner}, AH.tk(AH.dp({SI}, 2n), 32980n)))) : B.Buf & +List<U32>}}'
    w(f'  %Equal.sym(List<&2, U32>, [x0, x1], [F.flat__nthc({SI}, 0n), F.flat__nthc({SI}, 1n)], {{==}}) :')
    w('    ' + ctx2('_'))
    hlen = (f'F.logic__subst(Nat, z => {{Nat.is_le(2n, z) == True{{}} : Bool}}, 65536n, F.spec_common__length(U32, {SI}), '
            f'Equal.sym(Nat, F.spec_common__length(U32, {SI}), 65536n, AS.len_tree(16n, {I}, 65536n, {pI}, {{==}})), {{==}})')
    w(f'  %AH.tk2({SI}, {hlen}) :')
    w('    ' + ctx2('_'))
    w(f'  %AH.take_split_lit({SI}, 1n+32981n, 2n, 32980n, {{==}}, {{==}}) :')
    w(f'    {{B.emit({BUF}, 0, k) == ({BUF}, SF.limbs(_)) : B.Buf & +List<U32>}}')
    w(f'  AE.emit_take(16n, {I}, {n}, k, 32981n,')
    w(f'    F.logic__subst(U32, z => {{Nat.is_eq(U32.to_nat(z), 1n+32981n) == True{{}} : Bool}}, {nw}, k, Equal.sym(U32, k, {nw}, ek), {{==}}),')
    w(f'    {{==}}, {{==}}, {{==}}, {pI})')
    w('')
    # spec side over any blob words bw of 32768 words
    spec = f'Spec.{name}()'
    V = (f'S.Sequence{{S.Items{{S.UnsignedValue{{P.UInt{{x0, x1, 0, 0, 0, 0, 0, 0}}}}, S.Items{{S.BytesValue{{SF.limbs(bw)}}, '
         f'S.Items{{{fo[0]["val"]}, S.Items{{{fo[1]["val"]}, S.Items{{{fo[2]["val"]}, S.Items{{{fo[3]["val"]}, S.EmptyItems{{}}}}}}}}}}}}}}}}')
    hdr = (f'+x0: U32, +x1: U32, +bw: List<&2, U32>, +hbw: {{F.spec_common__length(U32, bw) == 32768n : Nat}}, '
           + ', '.join(f'+{x}: U32' for x in FS) + f', +s: S.Schema, +es: {{s == {spec} : S.Schema}}')
    args = 'x0, x1, bw, hbw, ' + ', '.join(FS) + ', s, es'
    PT = 'Maybe<&2, +List<S.Part>>'
    wss = [['x0', 'x1'], 'bw'] + [f_['words'] for f_ in fo]
    wsl = '[' + ', '.join(x if isinstance(x, str) else '[' + ', '.join(x) + ']' for x in wss) + ']'
    RHSF = f'Some{{[S.Fixed{{SF.flat({wsl})}}]}}'
    w(f'# the spec\'s parts of the value of index x0, x1, blob words bw and field words f at the schema')
    w('# one Items / Chain step of Codec.parts, over variables (stuck, so the conversion is small)')
    w('def pcs(+v: S.Value, +r: S.Value, +a: S.Schema, +b: S.Schema) -> {Codec.parts(S.Items{v, r}, S.Chain{a, b}) == Codec.concatenate(Codec.parts(v, a), Codec.parts(r, b)) : Maybe<&2, +List<S.Part>>}: {==}')
    w('')
    w(f'def {name}_spec_parts({hdr})')
    w(f'    -> {{Codec.parts({V}, s) == Some{{[S.Fixed{{{BY("bw")}}}]}} : {PT}}}:')
    gg = lambda sch, rhs: f'{{Codec.parts({V}, {sch}) == {rhs} : {PT}}}'
    w(f'  %Equal.sym(+List<U32>, SF.limbs(F.spec_common__append(U32, [x0, x1], F.spec_common__append(U32, bw, {FSL}))), List.append(&2, U32, SF.limbs([x0, x1]), SF.limbs(F.spec_common__append(U32, bw, {FSL}))), AS.limbs_app([x0, x1], F.spec_common__append(U32, bw, {FSL}))) :')
    w('    ' + gg('s', 'Some{[S.Fixed{_}]}'))
    w(f'  %Equal.sym(+List<U32>, SF.limbs(F.spec_common__append(U32, bw, {FSL})), List.append(&2, U32, SF.limbs(bw), SF.limbs({FSL})), AS.limbs_app(bw, {FSL})) :')
    w('    ' + gg('s', 'Some{[S.Fixed{List.append(&2, U32, SF.limbs([x0, x1]), _)}]}'))
    fs_ = 'SH.Container_fields(s)'
    tails = [fs_]
    for i in range(6):
        tails.append(f'SH.Chain_tail({tails[-1]})')
    heads = [f'SH.Chain_head({tails[i]})' for i in range(6)]
    names_ = 'SH.Container_names(s)'
    schs = ['S.Unsigned{P.U64{}}', f'S.ByteVector{{SH.ByteVector_length({heads[1]})}}', fo[0]['sch'], fo[1]['sch'], fo[2]['sch'], fo[3]['sch']]

    def chain(hs, k):
        out = 'S.End{}' if k == 6 else tails[6]
        for i in range(k - 1, -1, -1):
            out = f'S.Chain{{{hs[i]}, {out}}}'
        return out
    steps = [(f'Equal.sym(S.Schema, s, S.Container{{{names_}, {fs_}}}, SH.Container_shape(s, {bfact(spec, "SH.is_Container(s)")}))', '_')]
    cur = list(heads)
    for i in range(6):
        eq = f'Equal.sym(S.Schema, {tails[i]}, S.Chain{{{heads[i]}, {tails[i + 1]}}}, SH.Chain_shape({tails[i]}, {bfact(spec, f"SH.is_Chain({tails[i]})")}))'
        # the chain so far: heads[0..i-1] then _
        pre = 'S.Container{' + names_ + ', ' + ''.join(f'S.Chain{{{heads[j]}, ' for j in range(i)) + '_' + '}' * i + '}'
        steps.append((eq, pre))
    pre = 'S.Container{' + names_ + ', ' + ''.join(f'S.Chain{{{heads[j]}, ' for j in range(6)) + '_' + '}' * 6 + '}'
    steps.append((f'Equal.sym(S.Schema, {tails[6]}, S.End{{}}, SH.End_shape({tails[6]}, {bfact(spec, f"SH.is_End({tails[6]})")}))', pre))
    fin = list(heads)
    for i in range(6):
        if i == 1:
            eq = f'Equal.sym(S.Schema, {heads[1]}, S.ByteVector{{SH.ByteVector_length({heads[1]})}}, SH.ByteVector_shape({heads[1]}, {bfact(spec, f"SH.is_ByteVector({heads[1]})")}))'
        else:
            eq = f'Equal.sym(S.Schema, {heads[i]}, {schs[i]}, {sfact(spec, heads[i], schs[i])})'
        hs = fin[:i] + ['_'] + fin[i + 1:]
        steps.append((eq, f'S.Container{{{names_}, {chain(hs, 6)}}}'))
        fin[i] = schs[i]
    for eq, sch in steps:
        w(f'  %{eq} :')
        w('    ' + gg(sch, RHSF))
    FIELDS = chain(schs, 6)
    vals = ['S.UnsignedValue{P.UInt{x0, x1, 0, 0, 0, 0, 0, 0}}', 'S.BytesValue{SF.limbs(bw)}'] + [f_['val'] for f_ in fo]
    proofs = ['SF.uint64_part(x0, x1)', None] + [chainw(f_['proof']) for f_ in fo]
    parts = [f'Codec.parts({vals[i]}, {schs[i]})' for i in range(6)]
    fixed = [f'Some{{[S.Fixed{{SF.limbs({x if isinstance(x, str) else "[" + ", ".join(x) + "]"})}}]}}' for x in wss]

    def aggm(ps):
        out = 'Some{[]}'
        for p_ in reversed(ps):
            out = f'Codec.concatenate({p_}, {out})'
        return f'{{Codec.aggregate({out}, SSC.fixed_size({FIELDS})) == {RHSF} : {PT}}}'
    hw = (f'F.logic__subst(Nat, z => {{Nat.is_eq(z, 131072n) == True{{}} : Bool}}, 131072n, SF.wlen(bw), '
          f'Equal.sym(Nat, SF.wlen(bw), 131072n, AS.wlen_len(bw, 32768n, 131072n, hbw, {{==}})), {{==}})')
    bvp = (f'AS.bv_parts({schs[1]}, bw, 131072n, {{==}}, {bfact(spec, f"Nat.is_eq(SH.ByteVector_length({heads[1]}), 131072n)")}, {hw}, {{==}}, {{==}})')
    # open the container and its field chain by rewrites in the goal's exact form (seq_parts, one
    # Items/Chain step each): the field steps' motives are Codec.aggregate(Codec.concatenate(..)), and
    # converting Codec.parts(Sequence, Container) to that evaluated every field's parts
    ITEMS = lambda k: 'S.EmptyItems{}' if k == 6 else f'S.Items{{{vals[k]}, {ITEMS(k + 1)}}}'
    CH = lambda k: 'S.End{}' if k == 6 else f'S.Chain{{{schs[k]}, {CH(k + 1)}}}'
    VALS = f'S.Sequence{{{ITEMS(0)}}}'
    SCH = f'S.Container{{{names_}, {FIELDS}}}'
    w(f'  %Equal.sym({PT}, Codec.parts({VALS}, {SCH}), Codec.aggregate(Codec.parts({ITEMS(0)}, {FIELDS}), SSC.fixed_size({FIELDS})), VSQ.seq_parts({VALS}, {SCH}, {ITEMS(0)}, {names_}, {FIELDS}, {{==}}, {{==}})) :')
    w(f'    {{_ == {RHSF} : {PT}}}')

    def openm(k, hole):
        out = hole
        for j in range(k - 1, -1, -1):
            out = f'Codec.concatenate({parts[j]}, {out})'
        return f'{{Codec.aggregate({out}, SSC.fixed_size({FIELDS})) == {RHSF} : {PT}}}'
    for k in range(6):
        w(f'  %Equal.sym({PT}, Codec.parts({ITEMS(k)}, {CH(k)}), Codec.concatenate({parts[k]}, Codec.parts({ITEMS(k + 1)}, {CH(k + 1)})), pcs({vals[k]}, {ITEMS(k + 1)}, {schs[k]}, {CH(k + 1)})) :')
        w('    ' + openm(k, '_'))
    w(f'  %Equal.sym({PT}, Codec.parts(S.EmptyItems{{}}, S.End{{}}), Some{{[]}}, {{==}}) :')
    w('    ' + openm(6, '_'))
    cur = list(parts)
    for i in range(6):
        prf = bvp if i == 1 else proofs[i]
        hs = [fixed[j] if j < i else cur[j] for j in range(6)]
        hs[i] = '_'
        w(f'  %Equal.sym({PT}, {parts[i]}, {fixed[i]}, {prf}) :')
        w('    ' + aggm(hs))
    REST = f'Layout.fixed_size(SF.fparts({"[" + ", ".join("[" + ", ".join(x) + "]" for x in wss[2:]) + "]"}))'
    ea = (f'Equal.trans(Nat, List.length(&2, U32, SF.limbs(bw)), SF.wlen(bw), 131072n, AS.len_limbs(bw), '
          f'AS.wlen_len(bw, 32768n, 131072n, hbw, {{==}}))')
    w(f'  AS.agg({wsl}, AS.unsome(SSC.fixed_size({FIELDS})), {n}n,')
    w(f'    AH.add_mid(List.length(&2, U32, SF.limbs(bw)), 131072n, 8n, {REST}, {n}n, {ea}, {{==}}), {{==}})')
    w('')
    w(f'# encoder soundness against spec/codec.bend')
    w(f'def {name}_spec_encode({hdr})')
    w(f'    -> Decoding.decodes(s, {BY("bw")}, {V}):')
    w(f'  SF.encoding_of_parts(s, {V}, {BY("bw")}, {name}_spec_parts({args}))')
    w('')
    # encoder: the object's blob storage is [l | r] (l its 2^15 words, r free), the
    # other fields any words f and storage pads g; the output tree after the blob copy
    # is [sp(14) | rp(14)] (arr_enc.enc_copy), then the field writes compute
    pads = [q for f_ in fo for q in f_['pads']]
    SLR = slots('F.TNode{l, r}')
    OBJE = (f'{R}{{O.U64{{x0, x1}}, O.Words{{ANode{{{th("l")}, {th("r")}}}, 131072}}, '
            f'{fo[0]["objf"]}, {fo[1]["objf"]}, O.BSome{{{fo[2]["objf"]}, O.BNone{{}}}}, {fo[3]["objf"]}}}')
    eparams = (f'+l: {TV}, +r: {TV}, +pl: {pf(15, "l")}, +pr: {pf(15, "r")}, +x0: U32, +x1: U32, '
               + ', '.join(f'+{x}: U32' for x in FS + pads) + f', +k: U32, +ek: {{k == {nw} : U32}}')
    BYL = BY(slots('l'))
    RHS = f'({OBJE}, {BYL})'
    ET = f'{R} & +List<U32>'
    u0, u1 = f'F.flat__nthc({SLR}, 32766n)', f'F.flat__nthc({SLR}, 1n+32766n)'
    SPX = f'AN.sp(14n, 0n, {SLR}, l, x0, x1)'
    RF = ttree([u0, u1] + FS + ['0'] * 42)
    for j in range(8, 15):
        RF = f'F.TNode{{{RF}, F.array__trep(U32, {j}n, 0)}}'
    FIN = f'F.TNode{{{SPX}, {RF}}}'
    KC, KP, SBH, INC = fo[0]['objf'], fo[1]['objf'], f'O.BSome{{{fo[2]["objf"]}, O.BNone{{}}}}', fo[3]['objf']
    pre = f'T.{name}_pw0(0, 0, O.U64{{x0, x1}}, {KC}, {KP}, {SBH}, {INC}, '
    wrap = lambda inner: f'SF.emitted({R}, T.{name}_enc_out(T.{name}_put_drop({pre}{inner}))), k)'
    WS = f'O.Words{{{th("F.TNode{l, r}")}, 131072}}'
    pf16 = f'F.logic__and_intro(F.array__perfect(U32, 15n, l), F.array__perfect(U32, 15n, r), pl, pr)'
    w(f'# the encoder emits the index, the blob\'s words (storage [l | r], r free), then the other')
    w(f'# fields\' words, whatever the storage pads g of the inclusion proof are')
    w(f'def {name}_spec_bytes({eparams})')
    w(f'    -> {{SF.emitted({R}, T.{name}_encode({OBJE}), k) == {RHS} : {ET}}}:')
    w(f'  %Equal.sym(O.Words & Bool, O.words_ok({WS}, 131072, 131072, False{{}}, 1), ({WS}, True{{}}),')
    w(f'      AC.vok(16n, F.TNode{{l, r}}, 131072, 131072, 131072, False{{}}, 1, {{==}}, {{==}}, {{==}}, {{==}}, {pf16})) :')
    w(f'    {{{wrap("T.b131072_pk(O.out_at(16n), 8, _)")} == {RHS} : {ET}}}')
    CP = f'(F.array__thaw(U32, F.TNode{{AN.sp(14n, 0n, {SLR}, l, 0, 0), AN.rp(14n, {u0}, {u1})}}), {th("F.TNode{l, r}")})'
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy(32768, 0, 2, Array.new(U32, 16n, 0), {th("F.TNode{l, r}")}), {CP},')
    w(f'      AN.enc_copy(14n, 32768, 0, 2, 16n, F.TNode{{l, r}}, l, 32766n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {pf16}, {{==}})) :')
    w(f'    {{{wrap("T.b131072_pk_ok(O.put_fin(131072, O.pw_al_tail(True{}, 32768, 2, _)))")} == {RHS} : {ET}}}')
    BUFF = f'B.Buf{{F.array__thaw(U32, {FIN}), {n}}}'
    TK = f'F.spec_common__append(U32, {slots(SPX)}, AH.tk({slots(RF)}, 214n))'
    w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit({BUFF}, 0, k), ({BUFF}, SF.limbs({TK})),')
    w(f'      AN.emit_split(15n, {SPX}, {RF}, {n}, k, 32981n, 32768n, 214n,')
    w(f'        F.logic__subst(U32, z => {{Nat.is_eq(U32.to_nat(z), 1n+32981n) == True{{}} : Bool}}, {nw}, k, Equal.sym(U32, k, {nw}, ek), {{==}}),')
    w(f'        {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, F.logic__and_intro(F.array__perfect(U32, 15n, {SPX}), F.array__perfect(U32, 15n, {RF}), AN.pf_sp(14n, 0n, {SLR}, l, x0, x1), {{==}}))) :')
    w(f'    {{({OBJE}, SF.listed(_)) == {RHS} : {ET}}}')
    NB = f'AN.nsb(0n, 32766n, {SLR}, l)'
    w(f'  %Equal.sym(List<&2, U32>, {slots(SPX)}, Con{{x0, Con{{x1, {NB}}}}}, AN.slots_spb(14n, 0n, {SLR}, l, x0, x1, 32766n, {{==}})) :')
    w(f'    {{({OBJE}, SF.limbs(F.spec_common__append(U32, _, AH.tk({slots(RF)}, 214n)))) == {RHS} : {ET}}}')
    TAIL = 'Con{' + u0 + ', Con{' + u1 + ', ' + FSL + '}}'
    w(f'  %Equal.sym(List<&2, U32>, F.spec_common__append(U32, {NB}, {TAIL}), F.spec_common__append(U32, {slots("l")}, {FSL}),')
    w(f'      AN.fin({slots("l")}, {slots("r")}, {FSL}, 32766n, 32768n, l, AS.len_tree(15n, l, 32768n, pl, {{==}}), {{==}})) :')
    w(f'    {{({OBJE}, SF.limbs(Con{{x0, Con{{x1, _}}}})) == {RHS} : {ET}}}')
    w('  {==}')
    w('')
    reject(w, name, n, name, R)
    U = []
    unique(U.append, name, hdr, args, BY('bw'), V, by_var=True)
    return '\n'.join(L) + '\n', U


GHEAD = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T')
          .replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec') for x in HEAD]
UWIDTH = {1: 'P.U32Width{}', 2: 'P.U64{}', 4: 'P.U128{}', 8: 'P.U256{}'}


def uvec_tail(name, e, fname):
    """A generic Vector[uint(32e), 513]: 512e words that fill a perfect tree A of
    depth p = 9 + log2(e), then the e words G of the last element; buffer and
    storage of depth p + 1 = [A | R]. The decode, view, input and encoder laws
    take A spine-shaped (its first word literal, so Base.Array.size computes on the
    tail copy) and R with its first e words literal; the spec laws take any
    perfect A. arr_enc.cpt_tail is the copy of A then the tail."""
    lo = {1: 0, 2: 1, 4: 2, 8: 3}[e]
    p = 9 + lo
    P = 1 << p
    nw = P + e
    n = 4 * nw
    t = nw & 7
    m = nw - t
    Eb = m - P
    k = 513
    L = list(GHEAD) + ['import ./arr_shift.bend as AH', 'import ./arr_enc.bend as AN', '',
                       '# GENERATED by codegen/spec_laws.py (spec_arr.uvec_tail). Do not edit.',
                       f'# {name}: a vector of {k} unsigned integers of {4 * e} bytes, {n} bytes: {P} words then {e}.', '']
    w = L.append
    R_ = 'O.Words'
    G = [f'g{i}' for i in range(e)]
    GL = '[' + ', '.join(G) + ']'
    gsig = ', '.join(f'+{x}: U32' for x in G)
    A, pA, aparams = spine(p, 'x0', 'q')
    Rt, pR, rparams = head_chunk(p, lo, G, 'c')
    Rz, pRz, _ = head_chunk(p, lo, G, None, zero=True)
    TIN = f'F.TNode{{{A}, {Rt}}}'
    pTIN = f'F.logic__and_intro(F.array__perfect(U32, {p}n, {A}), F.array__perfect(U32, {p}n, {Rt}), {pA}, {pR})'
    DEC = f'F.TNode{{{A}, {Rz}}}'
    iparams = f'{aparams}, {gsig}, {rparams}'
    BUF = f'B.Buf{{{th(TIN)}, {n}}}'
    OBJ = f'O.Words{{{th(DEC)}, {n}}}'
    RT = f'B.Buf & Maybe<&1, {R_}>'
    D1 = f'F.array__trep(U32, {p + 1}n, 0)'
    tn = f'{t}n'
    blk = lambda S, pS: (f'AC.blk(U32.to_nat(U32.shrn({nw}, 3n)), Nat.add(F.spec_common__pow2({p}n), {Eb}n), 0, 0, 0n, 0n, {p + 1}n, {p + 1}n, {S}, {D1}, '
                         f'{{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {pS}, F.array__trep_perfect(U32, {p + 1}n, 0))')
    CP = lambda Tl, Tr: f'AC.cpt({p + 1}n, Nat.add(F.spec_common__pow2({p}n), {Eb}n), 0n, 0n, {D1}, {slots(f"F.TNode{{{Tl}, {Tr}}}")})'
    TAILC = lambda Tr: f'AC.cpt({p}n, {Eb}n, 0n, 0n, F.array__trep(U32, {p}n, 0), {slots(Tr)})'
    # the copies in the reader's / writer's own terms (arr_copy read_al / put_al):
    # no copy or fill loop is run on the literal sizes
    NWt = f'U32.shrn(({n} + 3 : U32), 2n)'
    N13 = f'Array.new(U32, {p + 1}n, 0)'
    ZOF = {}
    RDC = lambda S, T: f'({th(f"F.TNode{{{S}, {ZOF[T]}}}")}, {th(f"F.TNode{{{S}, {T}}}")})'
    def copy_def(dname, params, S, T, pS, a, b):
        w(f'def {dname}({params})')
        w(f'    -> {{O.acopy({NWt}, {a}, {b}, {N13}, {th(f"F.TNode{{{S}, {T}}}")}) == {RDC(S, T)} : Array<U32> & Array<U32>}}:')
        w(f'  %Equal.sym(Array<U32>, {N13}, {th(D1)}, F.array__new(U32, {p + 1}n, 0)) :')
        w(f'    {{O.acopy({NWt}, {a}, {b}, _, {th(f"F.TNode{{{S}, {T}}}")}) == {RDC(S, T)} : Array<U32> & Array<U32>}}')
        TW = f'F.TNode{{{S}, {T}}}'
        tl = f'O.ac_tail(U32.to_nat(({NWt} .&. 7 : U32)), ({a} + {NWt} - ({NWt} .&. 7 : U32) : U32), ({b} + {NWt} - ({NWt} .&. 7 : U32) : U32), @@)'
        blkx = (f'AC.blk(U32.to_nat(U32.shrn({NWt}, 3n)), Nat.add(F.spec_common__pow2({p}n), {Eb}n), {a}, {b}, 0n, 0n, {p + 1}n, {p + 1}n, {TW}, {D1}, '
                f'{{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {pS}, F.array__trep_perfect(U32, {p + 1}n, 0))')
        w(f'  %Equal.sym(Array<U32> & Array<U32>, O.ac_blk(U32.to_nat(U32.shrn({NWt}, 3n)), {a}, {b}, ({th(D1)}, {th(TW)})), ({th(CP(S, T))}, {th(TW)}), {blkx}) :')
        w(f'    {{{tl.replace("@@", "_")} == {RDC(S, T)} : Array<U32> & Array<U32>}}')
        CPa = f'AC.cpt({p + 1}n, Nat.add(F.spec_common__pow2({p}n), {Eb}n), 0n, 0n, {D1}, F.spec_common__append(U32, {slots(S)}, {slots(T)}))'
        w(f'  %Equal.sym(List<&2, U32>, {slots(TW)}, F.spec_common__append(U32, {slots(S)}, {slots(T)}), AC.slots_node({S}, {T})) :')
        w(f'    {{{tl.replace("@@", f"({th(f'AC.cpt({p + 1}n, Nat.add(F.spec_common__pow2({p}n), {Eb}n), 0n, 0n, {D1}, _)')}, {th(TW)})")} == {RDC(S, T)} : Array<U32> & Array<U32>}}')
        w(f'  %Equal.sym(F.array__Tree<U32>, {CPa}, F.TNode{{{S}, {TAILC(T)}}}, AN.cpt_tail_q({p}n, {p + 1}n, {{==}}, {Eb}n, {S}, {slots(T)}, {pA if S == A else pSE_})) :')
        w(f'    {{{tl.replace("@@", f"({th(chr(95))}, {th(TW)})")} == {RDC(S, T)} : Array<U32> & Array<U32>}}'.replace(th(chr(95)), th("_")))
        w('  {==}')
        w('')
    pSE_ = None
    ZOF[Rt] = Rz
    w(f'# the reader\'s copy of the first {nw} words into zero storage')
    copy_def(f'{name}_dec_copy', iparams, A, Rt, pTIN, 'U32.shrn(0, 2n)', '0')
    w(f'# decoding any buffer of {n} bytes accepts: the storage is the first {nw} words')
    w(f'def {name}_spec_decode({iparams})')
    w(f'    -> {{T.{name}_decode({BUF}, {n}) == ({BUF}, Some{{{OBJ}}}) : {RT}}}:')
    w(f'  %Equal.sym(B.Buf & O.Words, O.copy_into({BUF}, 0, {n}, {N13}), O.ci_fin({n}, {n}, {RDC(A, Rt)}),')
    w(f'      AC.read_al({th(TIN)}, {N13}, {n}, 0, {n}, {RDC(A, Rt)}, {{==}}, {{==}}, {name}_dec_copy({", ".join(pname(x) for x in split_params(iparams))}))) :')
    w(f'    {{T.{name}_some(_) == ({BUF}, Some{{{OBJ}}}) : {RT}}}')
    w('  {==}')
    w('')
    W_ = f'F.spec_common__append(U32, {slots(A)}, {GL})'
    w(f'# the bytes of that buffer: the words of A, then the {e} of the last element')
    # tk(slots R, e) == G down R's left spine (tk_left), so no take of a free tree is left
    chunks = [(ttree(G), '{==}')]
    for j in range(lo, p):
        Cj, pCj = chunks[-1]
        chunks.append((f'F.TNode{{{Cj}, c{j}}}', f'F.logic__and_intro(F.array__perfect(U32, {j}n, {Cj}), F.array__perfect(U32, {j}n, c{j}), {pCj}, pc{j})'))
    EQ = f'AH.tk({slots(chunks[0][0])}, {e}n)'
    for j in range(lo, p):
        Cj, pCj = chunks[j - lo]
        Cn = chunks[j - lo + 1][0]
        EQ = (f'Equal.trans(List<&2, U32>, AH.tk({slots(Cn)}, {e}n), AH.tk({slots(Cj)}, {e}n), {GL}, '
              f'AN.tk_left({j}n, {Cj}, c{j}, {e}n, {pCj}, {{==}}), {EQ if j > lo else "{==}"})')
    w(f'def {name}_spec_view({iparams})')
    w(f'    -> {{B.emit({BUF}, 0, {nw}) == ({BUF}, SF.limbs({W_})) : B.Buf & +List<U32>}}:')
    w(f'  %{EQ} :')
    w(f'    {{B.emit({BUF}, 0, {nw}) == ({BUF}, SF.limbs(F.spec_common__append(U32, {slots(A)}, _))) : B.Buf & +List<U32>}}')
    w(f'  AN.emit_split({p}n, {A}, {Rt}, {n}, {nw}, {nw - 1}n, {P}n, {e}n, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {pTIN})')
    w('')
    # input: the loader's buffer of the bytes of A's words then G
    zparams = f'{aparams}, {gsig}'
    zargs = ', '.join(['x0'] + [f'q{j}' for j in range(p)] + [f'pq{j}' for j in range(p)] + G
                      + [f'F.array__trep(U32, {j}n, 0)' for j in range(lo, p)] + [f'F.array__trep_perfect(U32, {j}n, 0)' for j in range(lo, p)])
    BUFZ = f'B.Buf{{{th(DEC)}, {n}}}'
    eL = (f'Equal.trans(Nat, F.spec_common__length(U32, {W_}), Nat.add(F.spec_common__length(U32, {slots(A)}), {e}n), Nat.add(F.spec_common__pow2({p}n), {e}n), '
          f'F.list__length_append(U32, {slots(A)}, {GL}), Equal.cong(Nat, Nat, z => Nat.add(z, {e}n), F.spec_common__length(U32, {slots(A)}), F.spec_common__pow2({p}n), F.array__slots_length(U32, {p}n, {A}, {pA})))')
    hfill = (f'F.logic__subst(Nat, z => {{Nat.is_le(Nat.add(z, 0n), F.spec_common__pow2({p + 1}n)) == True{{}} : Bool}}, Nat.add(F.spec_common__pow2({p}n), {e}n), '
             f'F.spec_common__length(U32, {W_}), Equal.sym(Nat, F.spec_common__length(U32, {W_}), Nat.add(F.spec_common__pow2({p}n), {e}n), {eL}), {{==}})')
    w(f'# the buffer the loader builds from the bytes of A\'s words then G is that buffer')
    w(f'def {name}_spec_load({zparams})')
    w(f'    -> {{B.fill_at(B.alloc({n}), 0, SF.limbs({W_})) == {BUFZ} : B.Buf}}:')
    w(f'  %Equal.sym(Nat, B.capacity({n}), {p + 1}n, {{==}}) : {{B.Buf{{B.fill_go(SF.limbs({W_}), Array.new(U32, _, 0), U32.shrn(0, 2n)), {n}}} == {BUFZ} : B.Buf}}')
    w(f'  %Equal.sym(Array<U32>, Array.new(U32, {p + 1}n, 0), {th(D1)}, F.array__new(U32, {p + 1}n, 0)) : {{B.Buf{{B.fill_go(SF.limbs({W_}), _, U32.shrn(0, 2n)), {n}}} == {BUFZ} : B.Buf}}')
    w(f'  %Equal.sym(Array<U32>, B.fill_go(SF.limbs({W_}), {th(D1)}, U32.shrn(0, 2n)), {th(f"AC.cpt({p + 1}n, F.spec_common__length(U32, {W_}), 0n, 0n, {D1}, {W_})")}, '
      f'AE.fill({W_}, {p + 1}n, {D1}, U32.shrn(0, 2n), 0n, {{==}}, {{==}}, {hfill}, F.array__trep_perfect(U32, {p + 1}n, 0))) :')
    w(f'    {{B.Buf{{_, {n}}} == {BUFZ} : B.Buf}}')
    w(f'  %Equal.sym(Nat, F.spec_common__length(U32, {W_}), Nat.add(F.spec_common__pow2({p}n), {e}n), {eL}) :')
    w(f'    {{B.Buf{{{th(f"AC.cpt({p + 1}n, _, 0n, 0n, {D1}, {W_})")}, {n}}} == {BUFZ} : B.Buf}}')
    w(f'  %Equal.sym(F.array__Tree<U32>, AC.cpt({p + 1}n, Nat.add(F.spec_common__pow2({p}n), {e}n), 0n, 0n, {D1}, {W_}), F.TNode{{{A}, AC.cpt({p}n, {e}n, 0n, 0n, F.array__trep(U32, {p}n, 0), {GL})}}, AN.cpt_tail_q({p}n, {p + 1}n, {{==}}, {e}n, {A}, {GL}, {pA})) :')
    w(f'    {{B.Buf{{{th("_")}, {n}}} == {BUFZ} : B.Buf}}')
    w('  {==}')
    w('')
    w(f'def {name}_spec_input({zparams})')
    w(f'    -> {{T.{name}_decode(B.fill_at(B.alloc({n}), 0, SF.limbs({W_})), {n}) == ({BUFZ}, Some{{{OBJ}}}) : {RT}}}:')
    w(f'  %Equal.sym(B.Buf, B.fill_at(B.alloc({n}), 0, SF.limbs({W_})), {BUFZ}, {name}_spec_load({", ".join(["x0"] + [f"q{j}" for j in range(p)] + [f"pq{j}" for j in range(p)] + G)})) :')
    w(f'    {{T.{name}_decode(_, {n}) == ({BUFZ}, Some{{{OBJ}}}) : {RT}}}')
    w(f'  {name}_spec_decode({zargs})')
    w('')
    # encoder
    SE, pSE, separams = spine(p, 'y0', 'r')
    H = [f'h{i}' for i in range(e)]
    HL = '[' + ', '.join(H) + ']'
    RE, pRE, reparams = head_chunk(p, lo, H, 'u')
    ZT, pZT, _ = head_chunk(p, lo, H, None, zero=True)
    ST = f'F.TNode{{{SE}, {RE}}}'
    pST = f'F.logic__and_intro(F.array__perfect(U32, {p}n, {SE}), F.array__perfect(U32, {p}n, {RE}), {pSE}, {pRE})'
    OBJE = f'O.Words{{{th(ST)}, {n}}}'
    eparams = f'{separams}, ' + ', '.join(f'+{x}: U32' for x in H) + f', {reparams}, +k: U32, +ek: {{k == {nw} : U32}}'
    BYE = f'SF.limbs(F.spec_common__append(U32, {slots(SE)}, {HL}))'
    RHS = f'({OBJE}, {BYE})'
    ET = f'{R_} & +List<U32>'
    ectx = lambda inner: f'{{SF.emitted({R_}, T.{name}_enc_out(O.put_fin({n}, {inner})), k) == {RHS} : {ET}}}'
    TOUT = f'F.TNode{{{SE}, {ZT}}}'
    pTOUT = f'F.logic__and_intro(F.array__perfect(U32, {p}n, {SE}), F.array__perfect(U32, {p}n, {ZT}), {pSE}, {pZT})'
    pSE_ = pSE
    ZOF[RE] = ZT
    w(f'# the writer\'s copy of the object\'s first {nw} words into the zero output')
    hsig = ', '.join(f'+{x}: U32' for x in H)
    copy_def(f'{name}_enc_copy', f'{separams}, {hsig}, {reparams}', SE, RE, pST, '0', 'U32.shrn(0, 2n)')
    w(f'# the encoder emits the words of the storage\'s first {nw} words (storage [A | R], R\'s words past them free)')
    w(f'def {name}_spec_bytes({eparams})')
    w(f'    -> {{SF.emitted({R_}, T.{name}_encode({OBJE}), k) == {RHS} : {ET}}}:')
    w(f'  %Equal.sym(Array<U32> & O.Words, O.put_words({N13}, 0, {OBJE}), O.put_fin({n}, {RDC(SE, RE)}),')
    w(f'      AC.put_al({N13}, {th(ST)}, 0, {n}, {RDC(SE, RE)}, {{==}}, {{==}}, {{==}}, {name}_enc_copy({", ".join(pname(x) for x in split_params(f"{separams}, {hsig}, {reparams}"))}))) :')
    w(f'    {{SF.emitted({R_}, T.{name}_enc_out(_), k) == {RHS} : {ET}}}')
    BUFO = f'B.Buf{{{th(TOUT)}, {n}}}'
    w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit({BUFO}, 0, k), ({BUFO}, SF.limbs(F.spec_common__append(U32, {slots(SE)}, AH.tk({slots(ZT)}, {e}n)))),')
    w(f'      AN.emit_split({p}n, {SE}, {ZT}, {n}, k, {nw - 1}n, {P}n, {e}n,')
    w(f'        F.logic__subst(U32, z => {{Nat.is_eq(U32.to_nat(z), 1n+{nw - 1}n) == True{{}} : Bool}}, {nw}, k, Equal.sym(U32, k, {nw}, ek), {{==}}),')
    w(f'        {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, {pTOUT})) :')
    w(f'    {{({OBJE}, SF.listed(_)) == {RHS} : {ET}}}')
    w('  {==}')
    w('')
    # spec side over any perfect A
    spec = f'Spec.{name}()'
    hdr = f'+t: {TV}, +pt: {pf(p, "t")}, {gsig}, +s: S.Schema, +es: {{s == {spec} : S.Schema}}'
    args = 't, pt, ' + ', '.join(G) + ', s, es'
    WT = f'F.spec_common__append(U32, {slots("t")}, {GL})'
    val = f'S.Sequence{{AV.chu{e}({WT})}}'
    ES = f'S.Unsigned{{{UWIDTH[e]}}}'
    hl = (f'Equal.trans(Nat, F.spec_common__length(U32, {WT}), Nat.add(F.spec_common__length(U32, {slots("t")}), F.spec_common__length(U32, {GL})), {nw}n, '
          f'F.list__length_append(U32, {slots("t")}, {GL}), Equal.cong(Nat, Nat, z => Nat.add(z, F.spec_common__length(U32, {GL})), F.spec_common__length(U32, {slots("t")}), {P}n, AS.len_tree({p}n, t, {P}n, pt, {{==}})))')
    w(f'def {name}_spec_parts({hdr})')
    w(f'    -> {{Codec.parts({val}, s) == Some{{[S.Fixed{{SF.limbs({WT})}}]}} : Maybe<&2, +List<S.Part>>}}:')
    w(f'  AV.vpartsu{e}(s, {WT}, {k}n, {nw}n, {n}n, {bfact(spec, "SH.is_Vector(s)")}, {sfact(spec, "SH.Vector_element(s)", ES)},')
    w(f'    {bfact(spec, f"Nat.is_eq(SH.Vector_length(s), {k}n)")}, {{==}}, {hl}, {{==}},')
    w(f'    AS.wlen_len({WT}, {nw}n, {n}n, {hl}, {{==}}), {{==}})')
    w('')
    w(f'def {name}_spec_encode({hdr})')
    w(f'    -> Decoding.decodes(s, SF.limbs({WT}), {val}):')
    w(f'  SF.encoding_of_parts(s, {val}, SF.limbs({WT}), {name}_spec_parts({args}))')
    w('')
    reject(w, name, n, fname, R_)
    U = []
    unique(U.append, name, hdr, args, f'SF.limbs({WT})', val, legal=f'VS.public_sound({spec}, {{==}})')
    return '\n'.join(L) + '\n', U


def uvec(name, p, e, fname):
    """A generic form: a vector of unsigned integers of e words each whose words
    fill a perfect tree of depth p (Vector[uint64/128/256, 512])."""
    n = 4 << p
    words = 1 << p
    k = words // e
    L = list(GHEAD) + ['', '# GENERATED by codegen/spec_laws.py (spec_arr.uvec). Do not edit.',
                       f'# {name}: a vector of {k} unsigned integers of {4 * e} bytes, {n} bytes, array-backed.', '']
    w = L.append
    R = 'O.Words'
    buf = lambda t: f'B.Buf{{{th(t)}, {n}}}'
    dec = f'O.Words{{ANode{{{th("t")}, Array.new(U32, {p}n, 0)}}, {n}}}'
    W = slots('t')
    w(f'# decoding any buffer of {n} bytes (every perfect tree t of depth {p}) accepts')
    w(f'def {name}_spec_decode(+t: {TV}, +pt: {pf(p, "t")})')
    w(f'    -> {{T.{name}_decode({buf("t")}, {n}) == ({buf("t")}, Some{{{dec}}}) : B.Buf & Maybe<&1, {R}>}}:')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({words}, 0, 0, Array.new(U32, {p + 1}n, 0), {th("t")}), (ANode{{{th("t")}, Array.new(U32, {p}n, 0)}}, {th("t")}),')
    w(f'      AC.zl1({p}n, {words}, 0, 0, t, {{==}}, {{==}}, {HK(p, words)}, {{==}}, {{==}}, pt)) :')
    w(f'    {{T.{name}_some(O.ci_fin({n}, {n}, _)) == ({buf("t")}, Some{{{dec}}}) : B.Buf & Maybe<&1, {R}>}}')
    w('  {==}')
    w('')
    w(f'def {name}_spec_view(+t: {TV}, +pt: {pf(p, "t")})')
    w(f'    -> {{B.emit({buf("t")}, 0, {words}) == ({buf("t")}, SF.limbs({W})) : B.Buf & +List<U32>}}:')
    w(f'  AE.emit_all({p}n, t, {n}, {words}, {words - 1}n, {{==}}, {{==}}, {{==}}, {{==}}, pt)')
    w('')
    w(f'def {name}_spec_input(+t: {TV}, +pt: {pf(p, "t")})')
    w(f'    -> {{T.{name}_decode(B.fill_at(B.alloc({n}), 0, SF.limbs({W})), {n}) == ({buf("t")}, Some{{{dec}}}) : B.Buf & Maybe<&1, {R}>}}:')
    w(f'  %Equal.sym(B.Buf, B.fill_at(B.alloc({n}), 0, SF.limbs({W})), {buf("t")}, AE.load_all({p}n, t, {n}, {{==}}, {{==}}, pt)) :')
    w(f'    {{T.{name}_decode(_, {n}) == ({buf("t")}, Some{{{dec}}}) : B.Buf & Maybe<&1, {R}>}}')
    w(f'  {name}_spec_decode(t, pt)')
    w('')
    obj = f'O.Words{{ANode{{{th("l")}, {th("r")}}}, {n}}}'
    w(f'def {name}_spec_bytes({trees(["l", "r"], p)})')
    w(f'    -> {{SF.emitted({R}, T.{name}_encode({obj}), {words}) == ({obj}, SF.limbs({slots("l")})) : {R} & +List<U32>}}:')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({words}, 0, 0, Array.new(U32, {p}n, 0), {th("F.TNode{l, r}")}), ({th("l")}, {th("F.TNode{l, r}")}),')
    w(f'      AC.ov({p}n, {words}, 0, 0, l, r, {{==}}, {{==}}, {HK(p, words)}, {{==}}, {{==}}, pl, pr)) :')
    w(f'    {{SF.emitted({R}, T.{name}_enc_out(O.put_fin({n}, _)), {words}) == ({obj}, SF.limbs({slots("l")})) : {R} & +List<U32>}}')
    w(f'  %Equal.sym(B.Buf & +List<U32>, B.emit(B.Buf{{{th("l")}, {n}}}, 0, {words}), (B.Buf{{{th("l")}, {n}}}, SF.limbs({slots("l")})), {name}_spec_view(l, pl)) :')
    w(f'    {{({obj}, SF.listed(_)) == ({obj}, SF.limbs({slots("l")})) : {R} & +List<U32>}}')
    w('  {==}')
    w('')
    spec = f'Spec.{name}()'
    hdr = f'+t: {TV}, +pt: {pf(p, "t")}, +s: S.Schema, +es: {{s == {spec} : S.Schema}}'
    val = f'S.Sequence{{AV.chu{e}({W})}}'
    ES = f'S.Unsigned{{{UWIDTH[e]}}}'
    w(f'def {name}_spec_parts({hdr})')
    w(f'    -> {{Codec.parts({val}, s) == Some{{[S.Fixed{{SF.limbs({W})}}]}} : Maybe<&2, +List<S.Part>>}}:')
    w(f'  AV.vpartsu{e}(s, {W}, {k}n, {words}n, {n}n, {bfact(spec, "SH.is_Vector(s)")}, {sfact(spec, "SH.Vector_element(s)", ES)},')
    w(f'    {bfact(spec, f"Nat.is_eq(SH.Vector_length(s), {k}n)")}, {{==}}, AS.len_tree({p}n, t, {words}n, pt, {{==}}), {{==}},')
    w(f'    AS.wlen_eq({p}n, t, {n}n, pt, {{==}}), {{==}})')
    w('')
    w(f'def {name}_spec_encode({hdr})')
    w(f'    -> Decoding.decodes(s, SF.limbs({W}), {val}):')
    w(f'  SF.encoding_of_parts(s, {val}, SF.limbs({W}), {name}_spec_parts(t, pt, s, es))')
    w('')
    reject(w, name, n, fname, R)
    U = []
    unique(U.append, name, hdr, 't, pt, s, es', f'SF.limbs({W})', val, legal=f'VS.public_sound({spec}, {{==}})')
    return '\n'.join(L) + '\n', U
