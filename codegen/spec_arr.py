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
    lg = legal or f'Legal.{name}_normative_legal()'
    if by_var:
        # the bytes as a variable `by` equal to them: with the 212 literal field words of
        # BlobSidecar, a parameter typed Decoding.decodes(s, <those bytes>, v) overflows
        # stock Bend's stack; the law is the same (by := the bytes, eby := {==})
        w(f'def {name}_spec_unique({hdr}, +by: +List<U32>, +eby: {{by == {bytes_} : +List<U32>}}, +v: S.Value, spec: Decoding.decodes(s, by, v))')
        w(f'    -> {{v == {val} : S.Value}}:')
        w(f'  E.image_unique(s, by, v, {val},')
        w(f'    F.logic__subst(S.Schema, z => TL.type_legal(z), {spec}, s, Equal.sym(S.Schema, s, {spec}, es), {lg}),')
        w(f'    spec, F.logic__subst(+List<U32>, z => Decoding.decodes(s, z, {val}), {bytes_}, by, Equal.sym(+List<U32>, by, {bytes_}, eby),')
        w(f'      SF.encoding_of_parts(s, {val}, {bytes_}, C.{name}_spec_parts({args}))))')
        w('')
        return
    w(f'def {name}_spec_unique({hdr}, +v: S.Value, spec: Decoding.decodes(s, {bytes_}, v))')
    w(f'    -> {{v == {val} : S.Value}}:')
    w(f'  E.image_unique(s, {bytes_}, v, {val},')
    w(f'    F.logic__subst(S.Schema, z => TL.type_legal(z), {spec}, s, Equal.sym(S.Schema, s, {spec}, es), {lg}),')
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
    w(f'      AC.zl1({p}n, {words}, 0, 0, t, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, pt)) :')
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
    w(f'      AC.ov({p}n, {words}, 0, 0, l, r, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, pl, pr)) :')
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
    L = list(HEAD) + ['', '# GENERATED by codegen/spec_laws.py (spec_arr.pair_vec). Do not edit.',
                      f'# {name}: two vectors of {k} byte vectors of {4 * e} bytes, {fb} bytes each, array-backed.', '']
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
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({words}, 0, 0, Array.new(U32, {p + 1}n, 0), {th("F.TNode{u, v}")}), ({A1}, {th("F.TNode{u, v}")}),')
    w(f'      AC.zl2({p}n, {words}, 0, 0, u, v, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, pu, pv)) :')
    w(f'    {{T.{name}_some(T.{name}_rd0(0, {n}, O.ci_fin({n}, {fb}, _))) == {RHS} : {RT}}}')
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({words}, {words}, 0, Array.new(U32, {p + 1}n, 0), {th("F.TNode{u, v}")}), (ANode{{{th("v")}, Array.new(U32, {p}n, 0)}}, {th("F.TNode{u, v}")}),')
    w(f'      AC.zl3({p}n, {words}, {words}, 0, u, v, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, pu, pv)) :')
    w(f'    {{T.{name}_some(T.{name}_rd1(0, {n}, O.Words{{{A1}, {fb}}}, O.ci_fin({n}, {fb}, _))) == {RHS} : {RT}}}')
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
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({words}, 0, 0, Array.new(U32, {p + 1}n, 0), {th("F.TNode{l1, r1}")}), ({A1}, {th("F.TNode{l1, r1}")}),')
    w(f'      AC.zl2({p}n, {words}, 0, 0, l1, r1, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, pl1, pr1)) :')
    w('    ' + ctx(f'T.{name}_pw0(0, 0, {SR}, T.{fname}_pk_ok(O.put_fin({fb}, _)))'))
    w(f'  %Equal.sym(O.Words & Bool, O.words_ok({SR}, {fb}, {fb}, False{{}}, {4 * e}), ({SR}, True{{}}), {vok("l2", "r2")}) :')
    w('    ' + ctx(f'T.{name}_pw1(0, 0, {BR}, T.{fname}_pk({A1}, (0 + {fb} : U32), _))'))
    w(f'  %Equal.sym(Array<U32> & Array<U32>, O.acopy({words}, 0, {words}, {A1}, {th("F.TNode{l2, r2}")}), (ANode{{{th("l1")}, {th("l2")}}}, {th("F.TNode{l2, r2}")}),')
    w(f'      AC.zr({p}n, {words}, 0, {words}, l1, l2, r2, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, pl1, pl2, pr2)) :')
    w('    ' + ctx(f'T.{name}_pw1(0, 0, {BR}, T.{fname}_pk_ok(O.put_fin({fb}, _)))'))
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
        return (f'AV.vparts{e}({V}, {W}, {k}n, {words}n, {fb}n, {{==}}, {{==}}, {kf}, {{==}}, AS.len_tree({p}n, {l}, {words}n, p{l}, {{==}}), {{==}}, '
                f'AS.wlen_eq({p}n, {l}, {fb}n, p{l}, {{==}}), {{==}})')
    P1 = f'Codec.parts(S.Sequence{{AV.ch{e}({W1})}}, {V1})'
    P2 = f'Codec.parts(S.Sequence{{AV.ch{e}({W2})}}, {V2})'
    F1 = f'Some{{[S.Fixed{{SF.limbs({W1})}}]}}'
    F2 = f'Some{{[S.Fixed{{SF.limbs({W2})}}]}}'
    w(f'  %Equal.sym({PT}, {P1}, {F1}, {vp(V1, h1, "l1", W1)}) :')
    w('    ' + agg('_', P2))
    w(f'  %Equal.sym({PT}, {P2}, {F2}, {vp(V2, h2, "l2", W2)}) :')
    w('    ' + agg(F1, '_'))
    x = f'Nat.add(Nat.mul(SH.Vector_length({h1}), {4 * e}n), Nat.add(Nat.mul(SH.Vector_length({h2}), {4 * e}n), 0n))'
    ea = lambda W, l: f'Equal.trans(Nat, List.length(&2, U32, SF.limbs({W})), SF.wlen({W}), {fb}n, AS.len_limbs({W}), AS.wlen_eq({p}n, {l}, {fb}n, p{l}, {{==}}))'
    w(f'  AS.agg([{W1}, {W2}], {x}, {n}n,')
    w(f'    AS.add2(List.length(&2, U32, SF.limbs({W1})), List.length(&2, U32, SF.limbs({W2})), {fb}n, {fb}n, {n}n, {ea(W1, "l1")}, {ea(W2, "l2")}, {{==}}), {{==}})')
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
         'import ../../spec/fulu_schemas.bend as Spec', 'import ../../spec/type_legality.bend as TL',
         'import ../decode_complete.bend as E', 'import ../../proofs/fulu_legality.bend as Legal',
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
    for name, (text, u) in [('Gt843A1262ED', uvec('Gt843A1262ED', 10, 2, 'v512_u64')),
                            ('Gt7274F61A0F', uvec('Gt7274F61A0F', 11, 4, 'v512_u128')),
                            ('Gt274A0B8DC2', uvec('Gt274A0B8DC2', 12, 8, 'v512_u256'))]:
        out[root / f'proofs/obj/spec_garr_{name}.bend'] = text
        gl = [x if x.startswith('import') else 'import ' + x for x in UHEAD]
        gl = [x.replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec')
               .replace('import ../../proofs/fulu_legality.bend as Legal', 'import ../type_validator_soundness.bend as VS') for x in gl]
        lines = gl + [f'import ./spec_garr_{name}.bend as C', '',
                 '# GENERATED by codegen/spec_laws.py (spec_arr). Do not edit.',
                 '# Completeness of the decoder\'s answer (decode_complete.image_unique; the legality of',
                 '# the generic schema from the checked validator, type_validator_soundness.public_sound).', ''] + u
        out[root / f'proofs/obj/spec_garr_unique_{name}.bend'] = '\n'.join(lines) + '\n'
        names.append((name, None))
    for name, u in names:
        if u is None:
            continue
        lines = [x if x.startswith('import') else 'import ' + x for x in UHEAD] + [f'import ./spec_arr_{name}.bend as C', '',
                 '# GENERATED by codegen/spec_laws.py (spec_arr). Do not edit.',
                 '# Completeness of the decoder\'s answer (decode_complete.image_unique, which END_TO_END',
                 '# .deserialize_unique is, with the',
                 '# name\'s legality witness, carried to the schema variable s == Spec.<N>()).', ''] + u
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
    L = list(HEAD) + ['', '# GENERATED by codegen/spec_laws.py (spec_arr.sync_committee). Do not edit.',
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


def blob_sidecar(name='BlobSidecar'):
    """index (2 words), blob (2^15 words at word 2: not aligned to the buffer's
    subtrees), kzg_commitment, kzg_proof (12 words each), signed_block_header (52
    words), kzg_commitment_inclusion_proof (136 words), 131928 bytes; buffer depth 16.

    Decoder, view, spec and uniqueness laws. The buffer is every perfect tree of
    depth 16 written [[x0, x1 | M1 | .. | M14] | [G | P8 | .. | P14]] with the
    first two words and the 256-word head G of the right half literal (so the
    field reads compute) and M_j, P_j free trees of depth j. The blob's storage is
    the canonical tree of the 2^15 words after the first two (arr_shift `bq`).
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
        small[f] = dict(obj=ren(nd.dec), val=sf(ren(nd.val)), sch=nd.sch, proof=sf(ren(nd.proof)), words=[ren(x) for x in nd.words])
        base += k
    assert base == 212, base
    FS = [f'f{i}' for i in range(212)]
    FSL = '[' + ', '.join(FS) + ']'
    L = list(HEAD) + ['import ./arr_shift.bend as AH', '', '# GENERATED by codegen/spec_laws.py (spec_arr.blob_sidecar). Do not edit.',
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
    proofs = ['SF.uint64_part(x0, x1)', None] + [f_['proof'] for f_ in fo]
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
    reject(w, name, n, name, R)
    U = []
    unique(U.append, name, hdr, args, BY('bw'), V, by_var=True)
    return '\n'.join(L) + '\n', U


GHEAD = [x.replace('../../types/fulu_obj.bend as T', '../../types/generic_obj.bend as T')
          .replace('../../spec/fulu_schemas.bend as Spec', './generic_specs.bend as Spec') for x in HEAD]
UWIDTH = {1: 'P.U32Width{}', 2: 'P.U64{}', 4: 'P.U128{}', 8: 'P.U256{}'}


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
    w(f'      AC.zl1({p}n, {words}, 0, 0, t, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, pt)) :')
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
    w(f'      AC.ov({p}n, {words}, 0, 0, l, r, {{==}}, {{==}}, {{==}}, {{==}}, {{==}}, pl, pr)) :')
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
