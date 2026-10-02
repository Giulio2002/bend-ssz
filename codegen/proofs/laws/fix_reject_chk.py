#!/usr/bin/env python3
"""ok_eval and decode_reject for the fixed-size names whose validator also checks bytes:
booleans (O.ok_bool) and vectors of booleans (every byte at most 1).

    python3 codegen/proofs/laws/fix_reject_chk.py [--check]

For such a name X of N bytes (validator T.<p>_ok), with ALLB(bs) = every byte of bs at most 1:
  <X>_ok_eval(d, t, n, off, x, e, hd, pf, hb, len)
      : {T.<p>_ok(UA.BF(t, n), off, len) == (UA.BF(t, n), Bool.and(U32.is_eq(len, N), ALLB(UW.WX(t, x, N))))}
      the validator on a buffer (a perfect word tree, off at byte position x, room for N
      bytes) returns the length check and ALLB of the N window bytes;
  <X>_decode_reject(bs, h: {Bool.and(Nat.is_eq(|bs|, N), ALLB(bs)) == False})
      : Decoding.outside_image(<schema>, bs)
      a byte list that fails that check (another length, or a byte above 1) is no encoding.
The spec side (every encoding at boolean / Vector[boolean, k] has bytes 0 and 1, and the
schema's size) and the runtime side (the window's bytes one at a time, the byte the runtime
reads) are proved once in proofs/obj/vrejb.bend (from codegen/templates/vrejb.bend.in); the names come
from the runtime (types/*_obj.bend: a validator O.ok_bool, or <p>_ok_n over O.ok_bool).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
from codegen.impl import runtime_refs as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports

from codegen.core.paths import ROOT  # noqa: E402
from codegen.core.shared_laws import finish  # noqa: E402
TRUE = 'True{} : Bool'
P = 'A.quad(VB.pw(d))'


def rows():
    from codegen.core import schema
    from codegen.core import generic
    fulu = list(schema.load(ROOT / 'codegen/fulu.yaml'))
    gen = [n for n, t, e in generic.inventory_all() if e is None]
    out = []
    for f, tag in (('fulu', 'f'), ('generic', 'g')):
        src = RR.mono_text(f)
        for m in re.finditer(r'^def (\w+)_decode\(buf: B\.Buf, \+size: U32\)[^\n]*\n  \w+\(size, (\w+)_ok\(buf, 0, size\)\)', src, re.M):
            X, p = m.group(1), m.group(2)
            if X not in fulu and X not in gen:
                continue
            ok = re.search(rf'^def {p}_ok\(buf: B\.Buf, \+off: U32, \+len: U32\) -> B\.Buf & Bool: {p}_ok_len\(U32\.is_eq\(len, (\d+)\), buf, off\)$', src, re.M)
            if not ok:
                continue
            N = int(ok.group(1))
            if re.search(rf'^def {p}_ok_at\(buf: B\.Buf, \+off: U32\) -> B\.Buf & Bool: O\.ok_bool\(buf, off\)$', src, re.M):
                out.append((X, tag, p, N, 'bool'))
            elif re.search(rf'^def {p}_ok_at\(buf: B\.Buf, \+off: U32\) -> B\.Buf & Bool: {p}_ok_n\(buf, off, {N}\)$', src, re.M) and \
                    re.search(rf'^def {p}_ck\(\+k: Nat, \+i: U32, \+off: U32, \+acc: Bool, pair: B\.Buf & Bool\)', src, re.M):
                out.append((X, tag, p, N, 'vec'))
    return out


def sig(name, extra=''):
    return (f'def {name}(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +off: U32, +x: Nat, +e: {{U32.to_nat(off) == x : Nat}},\n'
            f'    +hd: {{Nat.is_lt(d, 28n) == {TRUE}}}, +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}{extra})')


P32 = 'FD.spec_common__pow2(32n)'


def _with_deep(X, text, kind, N=None, K=None):
    """The validator laws (_ck, _at, _okl, _ok_eval) at any depth d < 31: twins X_ckD / X_atD / X_oklD / X_ok_evalD after the
    d < 28 originals (which stay, for the callers that have d < 28). A single byte at position y < x + N inside the tree needs
    only the strict-bound lemmas (VRB.okbD, UR.offx31); the byte loop of a vector adds the premise hs, the window's end
    x + N below 2^32 (every window of an n <= NMAX buffer), for the U32 position lemmas VRL.posU32 / succU32."""
    a = text.index(f'def {X}_ck(') if kind == 'vec' else text.index(f'def {X}_at(')
    if kind == 'vec':
        a = text.rindex('# the check loop', 0, a)
    b = text.index(f'def {X}_rj(')
    d = text[a:b]
    for old, new in [(f'{X}_ck', f'{X}_ckD'), (f'{X}_at', f'{X}_atD'), (f'{X}_okl', f'{X}_oklD'), (f'{X}_ok_eval', f'{X}_ok_evalD'),
                     ('Nat.is_lt(d, 28n)', 'Nat.is_lt(d, 31n)'), ('VRB.okb(', 'VRB.okbD(')]:
        if old == f'{X}_ck' and kind != 'vec':
            continue
        assert old in d, old
        d = d.replace(old, new)
    if kind == 'vec':
        HS = f'+hs: {{Nat.is_lt(Nat.add(x, {N}n), {P32}) == {TRUE}}}'
        # the loop's premise: the end of the remaining window below 2^32
        old = f'+hb: {{Nat.is_le(VRL.pos(Nat.add(1n+k, j), 1n, x), {P}) == {TRUE}}}'
        assert d.count(old) == 1, old
        d = d.replace(old, old + f', +hs: {{Nat.is_lt(VRL.pos(Nat.add(1n+k, j), 1n, x), {P32}) == {TRUE}}}')
        # the loop's step: the next byte's position and the counter, from the window's end
        old = '  +ex = VRL.posU(d, off, x, i, j, 1, 0n, {==}, e, ej, hd, hx)\n'
        assert d.count(old) == 1
        pe = 'VRL.pos(Nat.add(2n+q, j), 1n, x)'
        d = d.replace(old, f'  +hx32 = FD.nat__le_lt_trans(Nat.add(VRL.pos(1n+j, 1n, x), 1n), {pe}, {P32}, VRL.nextfit(j, q, 1n, x, {pe}, FD.nat__le_refl({pe})), hs)\n'
                      '  +ex = VRL.posU32(off, x, i, j, 1, 0n, {==}, e, ej, hx32)\n'
                      f'  +hs2 = FD.logic__subst(Nat, z => {{Nat.is_lt(VRL.pos(1n+z, 1n, x), {P32}) == {TRUE}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), '
                      'Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hs)\n')
        old = 'VRL.succU(d, i, j, 0n, x, ej, hd, hx), hd, pf, hb2)'
        assert d.count(old) == 1
        d = d.replace(old, 'VRL.succU32(i, j, 0n, x, ej, hx32), hd, pf, hb2, hs2)')
        # _at: the whole window's end
        old = f'  {X}_ckD({N - 1}n, d, t, n, off, x, 0, 0n, True{{}}, e, {{==}}, hd, pf, hk)\n'
        assert d.count(old) == 1, old
        d = d.replace(old, f'  +hk32 = FD.logic__subst(Nat, z => {{Nat.is_lt(z, {P32}) == {TRUE}}}, Nat.add(x, {N}n), Nat.add({N}n, x), FD.nat__add_comm(x, {N}n), hs)\n'
                      f'  {X}_ckD({N - 1}n, d, t, n, off, x, 0, 0n, True{{}}, e, {{==}}, hd, pf, hk, hk32)\n')
        # _at / _okl / _ok_eval carry hs after hb
        hb = f'+hb: {{Nat.is_le(Nat.add(x, {N}n), {P}) == {TRUE}}}'
        assert d.count(hb) == 3, d.count(hb)
        d = d.replace(hb, hb + ', ' + HS)
        for nm in ('_oklD', '_atD'):
            pass
        old = 'd, t, n, off, x, e, hd, pf, hb'
        d = d.replace(f'{X}_atD({old})', f'{X}_atD({old}, hs)').replace(f'{X}_oklD({old}, U32.is_eq(len, {N}))', f'{X}_oklD({old}, hs, U32.is_eq(len, {N}))')
    if kind == 'validator':
        d, n1 = re.subn(r'UR\.offx\(d, off, (\d+), x, e, FD\.nat__lt_trans\(d, 28n, 30n, hd, \{==\}\), hy\)', r'UR.offx31(d, off, \1, x, e, hd, hy)', d)
        assert n1 == 1, n1
    assert 'Nat.is_lt(d, 28n)' not in d and 'lt_trans(d, 28n' not in d, [l for l in d.split('\n') if 'lt_trans(d, 28n' in l][:2]
    return text[:b] + d + text[b:]


def name_text(X, tag, p, N, kind):
    s = f'{"Spec" if tag == "f" else "GS"}.{X}()'
    W = f'UW.WX(t, x, {N}n)'
    BF = 'UA.BF(t, n)'
    L = [f'# ---- {X} ({N} bytes; validator T.{p}_ok: {"a boolean byte" if kind == "bool" else "every byte a boolean"}) ----']
    hb = f',\n    +hb: {{Nat.is_le(Nat.add(x, {N}n), {P}) == {TRUE}}}'
    if kind == 'vec':
        y = 'VRL.pos(j, 1n, x)'
        y1 = 'VRL.pos(1n+j, 1n, x)'
        L.append(f'''# the check loop from byte j (index i) on: acc and ALLB of the next 1 + k window bytes
def {X}_ck(+k: Nat, +d: Nat, +t: FD.array__Tree<U32>, +n: U32, +off: U32, +x: Nat, +i: U32, +j: Nat, +acc: Bool,
    +e: {{U32.to_nat(off) == x : Nat}}, +ej: {{U32.to_nat(i) == j : Nat}}, +hd: {{Nat.is_lt(d, 28n) == {TRUE}}},
    +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}}, +hb: {{Nat.is_le(VRL.pos(Nat.add(1n+k, j), 1n, x), {P}) == {TRUE}}})
    -> {{T.{p}_ck(k, i, off, acc, ({BF}, U32.is_le(VRB.BX(t, {y}), 1))) == ({BF}, Bool.and(acc, VRB.ALLB(UW.WX(t, {y}, 1n+k)))) : B.Buf & Bool}}:
  match k:
    case 0n:
    +hy = FD.nat__lt_le_trans({y}, 1n+{y}, {P}, FD.nat__lt_succ({y}), FD.nat__le_trans(1n+{y}, VRL.pos(Nat.add(1n+k, j), 1n, x), {P}, VRB.pmk(k, j, x), hb))
      %Equal.sym(+List<U32>, UW.WX(t, {y}, 1n), Con{{VRB.BX(t, {y}), UW.WX(t, 1n+{y}, 0n)}}, VRB.wxc(d, t, {y}, 0n, pf, hy)) :
        {{({BF}, Bool.and(acc, U32.is_le(VRB.BX(t, {y}), 1))) == ({BF}, Bool.and(acc, VRB.ALLB(_))) : B.Buf & Bool}}
      %Equal.sym(Bool, Bool.and(U32.is_le(VRB.BX(t, {y}), 1), True{{}}), U32.is_le(VRB.BX(t, {y}), 1), VRB.and_true(U32.is_le(VRB.BX(t, {y}), 1))) :
        {{({BF}, Bool.and(acc, U32.is_le(VRB.BX(t, {y}), 1))) == ({BF}, Bool.and(acc, _)) : B.Buf & Bool}}
      {{==}}
    case 1n+ +q:
    +hy = FD.nat__lt_le_trans({y}, 1n+{y}, {P}, FD.nat__lt_succ({y}), FD.nat__le_trans(1n+{y}, VRL.pos(Nat.add(1n+k, j), 1n, x), {P}, VRB.pmk(k, j, x), hb))
      +c = U32.is_le(VRB.BX(t, {y}), 1)
      +R = VRB.ALLB(UW.WX(t, {y1}, 1n+q))
      +hx = VRL.nextfit(j, q, 1n, x, {P}, hb)
      +ex = VRL.posU(d, off, x, i, j, 1, 0n, {{==}}, e, ej, hd, hx)
      +hx1 = FD.nat__lt_le_trans({y1}, Nat.add({y1}, 1n), {P}, VTX.ltp({y1}, 0n), hx)
      +hb2 = FD.logic__subst(Nat, z => {{Nat.is_le(VRL.pos(1n+z, 1n, x), {P}) == {TRUE}}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hb)
      %Equal.sym(+List<U32>, UW.WX(t, {y}, 2n+q), Con{{VRB.BX(t, {y}), UW.WX(t, 1n+{y}, 1n+q)}}, VRB.wxc(d, t, {y}, 1n+q, pf, hy)) :
        {{T.{p}_ck(1n+q, i, off, acc, ({BF}, c)) == ({BF}, Bool.and(acc, VRB.ALLB(_))) : B.Buf & Bool}}
      %VRB.and_assoc(acc, c, R) : {{T.{p}_ck(1n+q, i, off, acc, ({BF}, c)) == ({BF}, _) : B.Buf & Bool}}
      %Equal.sym(B.Buf & Bool, O.ok_bool({BF}, U32.add(off, U32.mul(U32.add(i, 1), 1))), ({BF}, U32.is_le(VRB.BX(t, {y1}), 1)),
          VRB.okb(d, t, n, U32.add(off, U32.mul(U32.add(i, 1), 1)), {y1}, ex, hd, pf, hx1)) :
        {{T.{p}_ck(q, U32.add(i, 1), off, Bool.and(acc, c), _) == ({BF}, Bool.and(Bool.and(acc, c), R)) : B.Buf & Bool}}
      {X}_ck(q, d, t, n, off, x, U32.add(i, 1), 1n+j, Bool.and(acc, c), e, VRL.succU(d, i, j, 0n, x, ej, hd, hx), hd, pf, hb2)
''')
        at = f'''def {X}_at({sig('_', hb).replace('def _(', '').rstrip(')')})
    -> {{T.{p}_ok_at({BF}, off) == ({BF}, VRB.ALLB({W})) : B.Buf & Bool}}:
  +hx = FD.nat__lt_le_trans(x, Nat.add(x, {N}n), {P}, VTX.ltp(x, {N - 1}n), hb)
  +hk = FD.logic__subst(Nat, z => {{Nat.is_le(z, {P}) == {TRUE}}}, Nat.add(x, {N}n), Nat.add({N}n, x), FD.nat__add_comm(x, {N}n), hb)
  %Equal.sym(B.Buf & Bool, O.ok_bool({BF}, off), ({BF}, U32.is_le(VRB.BX(t, x), 1)), VRB.okb(d, t, n, off, x, e, hd, pf, hx)) :
    {{T.{p}_ck({N - 1}n, 0, off, True{{}}, _) == ({BF}, VRB.ALLB({W})) : B.Buf & Bool}}
  {X}_ck({N - 1}n, d, t, n, off, x, 0, 0n, True{{}}, e, {{==}}, hd, pf, hk)
'''
        L.append(at.replace('def (+', f'def {X}_at(+'))
    else:
        L.append(f'''def {X}_at({sig('_', hb).replace('def _(', '').rstrip(')')})
    -> {{T.{p}_ok_at({BF}, off) == ({BF}, VRB.ALLB({W})) : B.Buf & Bool}}:
  +hx = FD.nat__lt_le_trans(x, Nat.add(x, 1n), {P}, VTX.ltp(x, 0n), hb)
  %Equal.sym(B.Buf & Bool, O.ok_bool({BF}, off), ({BF}, U32.is_le(VRB.BX(t, x), 1)), VRB.okb(d, t, n, off, x, e, hd, pf, hx)) :
    {{_ == ({BF}, VRB.ALLB({W})) : B.Buf & Bool}}
  %Equal.sym(+List<U32>, {W}, Con{{VRB.BX(t, x), UW.WX(t, 1n+x, 0n)}}, VRB.wxc(d, t, x, 0n, pf, hx)) :
    {{({BF}, U32.is_le(VRB.BX(t, x), 1)) == ({BF}, VRB.ALLB(_)) : B.Buf & Bool}}
  %Equal.sym(Bool, Bool.and(U32.is_le(VRB.BX(t, x), 1), True{{}}), U32.is_le(VRB.BX(t, x), 1), VRB.and_true(U32.is_le(VRB.BX(t, x), 1))) :
    {{({BF}, U32.is_le(VRB.BX(t, x), 1)) == ({BF}, _) : B.Buf & Bool}}
  {{==}}
''')
    args = 'd, t, n, off, x, e, hd, pf, hb'
    L.append(f'''def {X}_okl({sig('_', hb).replace('def _(', '').rstrip(')')}, +b: Bool)
    -> {{T.{p}_ok_len(b, {BF}, off) == ({BF}, Bool.and(b, VRB.ALLB({W}))) : B.Buf & Bool}}:
  match b:
    case True{{}}: {X}_at({args})
    case False{{}}: {{==}}

# the validator returns the length check and ALLB of the N window bytes
def {X}_ok_eval({sig('_', hb).replace('def _(', '').rstrip(')')}, +len: U32)
    -> {{T.{p}_ok({BF}, off, len) == ({BF}, Bool.and(U32.is_eq(len, {N}), VRB.ALLB({W}))) : B.Buf & Bool}}:
  {X}_okl({args}, U32.is_eq(len, {N}))

def {X}_rj(+bs: +List<U32>, +h: {{Bool.and(Nat.is_eq(List.length(&2, U32, bs), {N}n), VRB.ALLB(bs)) == False{{}} : Bool}}, +v: S.Value, +e: {{Codec.encoding_for_legal_type({s}, v) == Some{{bs}} : Maybe<&2, +List<U32>>}}) -> Empty:
  VRB.chk_true(Nat.is_eq(List.length(&2, U32, bs), {N}n), VRB.ALLB(bs),
    VRB.len_eq(SS.fixed_size({s}), {N}n, bs, Codec.parts(v, {s}), DS.facts(v, {s}, {{==}}), {{==}}, e),
    {"VRB.boolb(v, bs, e)" if kind == "bool" else f"VRB.vecb(v, {N}n, bs, e)"}, h)

# a byte list of another length, or with a byte above 1, is no encoding
def {X}_decode_reject(+bs: +List<U32>, +h: {{Bool.and(Nat.is_eq(List.length(&2, U32, bs), {N}n), VRB.ALLB(bs)) == False{{}} : Bool}}) -> Decoding.outside_image({s}, bs):
  v => e => {X}_rj(bs, h, v, e)
''')
    return _with_deep(X, '\n'.join(L), kind, N)


def module(tag, rs):
    T = '../../types/fulu_obj.bend' if tag == 'f' else '../../types/generic_obj.bend'
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import {T} as T',
         'import ../../types/schema.bend as S', 'import ../../spec/codec.bend as Codec', 'import ../../spec/decoding_relation.bend as Decoding',
         'import ../../spec/schema.bend as SS', 'import ../../proofs/decode_shape.bend as DS',
         'import ../../spec/fulu_schemas.bend as Spec' if tag == 'f' else 'import ./generic_specs.bend as GS',
         'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ./vbuf.bend as VB', 'import ./vua.bend as UA',
         'import ./vua_win.bend as UW', 'import ./vua_fix.bend as VTX', 'import ./vrl.bend as VRL', 'import ./vrejb.bend as VRB', '',
         '# GENERATED by fix_reject_chk (codegen). Do not edit.',
         '# Fixed-size names whose validator checks boolean bytes: ok_eval and decode_reject (see the generator).', '']
    for r in rs:
        L.append(name_text(*r))
    return '\n'.join(L) + '\n'


def outputs():
    rs = rows()
    out = {ROOT / 'proofs/obj/vrejb.bend': (ROOT / 'codegen/templates/vrejb.bend.in').read_text()}
    for tag in ('f', 'g'):
        sub = [r for r in rs if r[1] == tag]
        if sub:
            out[ROOT / f'proofs/obj/fixchk_bool{tag}.bend'] = module(tag, sub)
    out[ROOT / 'proofs/obj/fixchk_Validator.bend'] = validator_text()
    return out


def main():
    out = outputs()
    if finish(out, (), 'stale: ', 'boolean-check reject laws are current'):
        print(f'{len(out)} files: ' + ', '.join(r[0] for r in rows()))



# ---- Validator: the slashed byte at 88 -------------------------------------------------------------

VAL_OTHERS = ['BooleanValue{+b}', 'UnsignedValue{+u}', 'BytesValue{+xs}', 'BitsValue{+bb}', 'Sequence{+it}', 'Items{+hh, +tt}',
              'EmptyItems{}', 'Selected{+sel, +sv}', 'NullValue{}']


def validator_text():
    """Validator (121 bytes; its validator checks byte 88, the slashed boolean, is at most 1)."""
    X, p, N, K = 'Validator', 'Validator', 121, 88
    TR = 'FD.array__Tree<U32>'
    BF = 'UA.BF(t, n)'
    W = f'UW.WX(t, x, {N}n)'
    CK = lambda bs: f'U32.is_le(VBL.nthb({bs}, {K}n), 1)'
    BY = lambda ps: f'List.append(&2, U32, Layout.fixed_parts({ps}, o), Layout.payloads({ps}))'
    # the chain from each field on
    fields = ['Spec.Schema8()', 'Spec.Schema7()', 'Spec.Schema3()', 'Spec.Schema0()'] + ['Spec.Schema3()'] * 4
    def chain(i):
        return 'S.End{}' if i == len(fields) else f'S.Chain{{{fields[i]}, {chain(i + 1)}}}'
    sig = (f'+d: Nat, +t: {TR}, +n: U32, +off: U32, +x: Nat, +e: {{U32.to_nat(off) == x : Nat}},\n'
           f'    +hd: {{Nat.is_lt(d, 28n) == {TRUE}}}, +pf: {{FD.array__perfect(U32, d, t) == {TRUE}}},\n'
           f'    +hb: {{Nat.is_le(Nat.add(x, {N}n), {P}) == {TRUE}}}')
    args = 'd, t, n, off, x, e, hd, pf, hb'
    y = f'Nat.add({K}n, x)'
    goalK = lambda ps, k: f'{{U32.is_le(VBL.nthb({BY(ps)}, {k}), 1) == {TRUE}}}'
    L = [f'''# ---- {X} ({N} bytes; validator T.{p}_ok: the slashed byte {K} at most 1) ----

# byte k of (a ++ b) ++ c past a
def nth_skip(+a: +List<U32>, +b: +List<U32>, +c: +List<U32>, +k: Nat)
    -> {{VBL.nthb(List.append(&2, U32, List.append(&2, U32, a, b), c), Nat.add(List.length(&2, U32, a), k)) == VBL.nthb(List.append(&2, U32, b, c), k) : U32}}:
  match a:
    case Nil{{}}: {{==}}
    case Con{{+h, +r}}: nth_skip(r, b, c, k)

# a fixed field of w bytes, then the rest (whose byte K is checked by k)
def skip(+w: Nat, +K: Nat, +o: Nat, +m1: Maybe<&2, +List<S.Part>>, hf: DF.single_result(Some{{w}}, m1), +m2: Maybe<&2, +List<S.Part>>, +ps: +List<S.Part>,
    +e: {{Codec.concatenate(m1, m2) == Some{{ps}} : Maybe<&2, +List<S.Part>>}},
    k: @+q: +List<S.Part> -> {{m2 == Some{{q}} : Maybe<&2, +List<S.Part>>}} -> {goalK("q", "K")})
    -> {goalK("ps", "Nat.add(w, K)")}:
  match m1:
    case None{{}}: Empty.absurd({goalK("ps", "Nat.add(w, K)")}, FD.logic__none_some(+List<S.Part>, ps, e))
    case Some{{+p1}}:
      match p1:
        case Nil{{}}: Empty.absurd({goalK("ps", "Nat.add(w, K)")}, hf)
        case Con{{S.Variable{{+x1}}, +r1}}: Empty.absurd({goalK("ps", "Nat.add(w, K)")}, vk(w, x1, r1, hf))
        case Con{{S.Fixed{{+x1}}, +r1}}:
          match r1:
            case Con{{+a1, +b1}}: Empty.absurd({goalK("ps", "Nat.add(w, K)")}, hf)
            case Nil{{}}:
              match m2:
                case None{{}}: Empty.absurd({goalK("ps", "Nat.add(w, K)")}, FD.logic__none_some(+List<S.Part>, ps, e))
                case Some{{+q}}:
                  +eps = FD.logic__some_inj(+List<S.Part>, S.Fixed{{x1}} <> q, ps, e)
                  +ew = FD.logic__some_inj(Nat, w, List.length(&2, U32, x1), hf)
                  %Equal.sym(+List<S.Part>, ps, S.Fixed{{x1}} <> q, Equal.sym(+List<S.Part>, S.Fixed{{x1}} <> q, ps, eps)) : {goalK("_", "Nat.add(w, K)")}
                  %Equal.sym(Nat, w, List.length(&2, U32, x1), ew) : {{U32.is_le(VBL.nthb({BY("S.Fixed{x1} <> q")}, Nat.add(_, K)), 1) == {TRUE}}}
                  %Equal.sym(U32, VBL.nthb({BY("S.Fixed{x1} <> q")}, Nat.add(List.length(&2, U32, x1), K)), VBL.nthb({BY("q")}, K),
                      nth_skip(x1, Layout.fixed_parts(q, o), Layout.payloads(q), K)) : {{U32.is_le(_, 1) == {TRUE}}}
                  k(q, {{==}})
''']
    # vk: a variable part where a fixed one of width w is expected
    L.insert(0, f'''def vk(+w: Nat, +x1: +List<U32>, +r1: +List<S.Part>, hf: DF.single(Some{{w}}, S.Variable{{x1}} <> r1)) -> Empty:
  match r1:
    case Nil{{}}: FD.logic__none_some(Nat, w, Equal.sym(Maybe<&2, Nat>, Some{{w}}, None{{}}, hf))
    case Con{{+a, +b}}: hf
''')
    # the levels: fields 0..2 fixed (48, 32, 8 bytes), field 3 the boolean
    widths = [48, 32, 8]
    rest = [K - sum(widths[:i + 1]) for i in range(3)]      # 40, 8, 0
    for i in (3, 2, 1, 0):
        Ki = K - sum(widths[:i])
        head = f'def lvl{i}(+items: S.Value, +ps: +List<S.Part>, +o: Nat, +em: {{Codec.parts(items, {chain(i)}) == Some{{ps}} : Maybe<&2, +List<S.Part>>}})\n    -> {goalK("ps", f"{Ki}n")}:'
        absurd = f'Empty.absurd({goalK("ps", f"{Ki}n")}, FD.logic__none_some(+List<S.Part>, ps, em))'
        body = ['  match items:']
        if i < 3:
            body.append(f'    case S.Items{{+h, +r}}: skip({widths[i]}n, {rest[i]}n, o, Codec.parts(h, {fields[i]}), DS.facts(h, {fields[i]}, {{==}}), Codec.parts(r, {chain(i + 1)}), ps, em, q => eq => lvl{i + 1}(r, q, o, eq))')
        else:
            body.append('    case S.Items{+h, +r}:')
            body.append('      match h:')
            body.append(f'        case S.BooleanValue{{+b}}: bat(b, Codec.parts(r, {chain(4)}), ps, o, em)')
            for c in VAL_OTHERS:
                if c != 'BooleanValue{+b}':
                    body.append(f'        case S.{c}: {absurd}')
        for c in VAL_OTHERS:
            if not c.startswith('Items'):
                body.append(f'    case S.{c}: {absurd}')
        L.append(head + '\n' + '\n'.join(body) + '\n')
    lv = L[2:]
    L = L[:2] + [f'''# the boolean field: its byte is 0 or 1
def bat2(+b: Bool, +q: +List<S.Part>, +o: Nat) -> {goalK("S.Fixed{SP.boolean_encoding(b)} <> q", "0n")}:
  match b:
    case True{{}}: {{==}}
    case False{{}}: {{==}}
def bat(+b: Bool, +m2: Maybe<&2, +List<S.Part>>, +ps: +List<S.Part>, +o: Nat,
    +e: {{Codec.concatenate(Some{{[S.Fixed{{SP.boolean_encoding(b)}}]}}, m2) == Some{{ps}} : Maybe<&2, +List<S.Part>>}})
    -> {goalK("ps", "0n")}:
  match m2:
    case None{{}}: Empty.absurd({goalK("ps", "0n")}, FD.logic__none_some(+List<S.Part>, ps, e))
    case Some{{+q}}:
      +eps = FD.logic__some_inj(+List<S.Part>, S.Fixed{{SP.boolean_encoding(b)}} <> q, ps, e)
      %Equal.sym(+List<S.Part>, ps, S.Fixed{{SP.boolean_encoding(b)}} <> q, Equal.sym(+List<S.Part>, S.Fixed{{SP.boolean_encoding(b)}} <> q, ps, eps)) : {goalK("_", "0n")}
      bat2(b, q, o)
'''] + lv
    ABS = lambda: ''.join(f"    case S.{c}: Empty.absurd({{{CK('bs')} == {TRUE}}}, FD.logic__none_some(+List<U32>, bs, e))\n" for c in VAL_OTHERS if not c.startswith('Sequence'))
    L.append(f'''# every encoding at Validator: its byte {K} is 0 or 1
def pv_r(+ps: +List<S.Part>, +items: S.Value, +em: {{Codec.parts(items, {chain(0)}) == Some{{ps}} : Maybe<&2, +List<S.Part>>}},
    +w: Maybe<&2, Nat>, +bs: +List<U32>, +r: Maybe<&2, +List<U32>>, +er: {{Layout.encoding(ps) == r : Maybe<&2, +List<U32>>}},
    +e: {{Codec.bytes(Codec.one(r, w)) == Some{{bs}} : Maybe<&2, +List<U32>>}})
    -> {{{CK("bs")} == {TRUE}}}:
  match r:
    case None{{}}: Empty.absurd({{{CK("bs")} == {TRUE}}}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{{+xs}}:
      +c = Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(Layout.fixed_size(ps), List.length(&2, U32, Layout.payloads(ps)))))
      +e1 = VRB.opt_some(c, List.append(&2, U32, Layout.fixed_parts(ps, Layout.fixed_size(ps)), Layout.payloads(ps)), xs, er)
      FD.logic__subst(+List<U32>, z => {{{CK("z")} == {TRUE}}}, List.append(&2, U32, Layout.fixed_parts(ps, Layout.fixed_size(ps)), Layout.payloads(ps)), bs,
        Equal.trans(+List<U32>, List.append(&2, U32, Layout.fixed_parts(ps, Layout.fixed_size(ps)), Layout.payloads(ps)), xs, bs, e1, VRB.frag(w, xs, bs, e)),
        lvl0(items, ps, Layout.fixed_size(ps), em))
def pv_m(+items: S.Value, +m: Maybe<&2, +List<S.Part>>, +em: {{Codec.parts(items, {chain(0)}) == m : Maybe<&2, +List<S.Part>>}},
    +w: Maybe<&2, Nat>, +bs: +List<U32>, +e: {{Codec.bytes(Codec.aggregate(m, w)) == Some{{bs}} : Maybe<&2, +List<U32>>}})
    -> {{{CK("bs")} == {TRUE}}}:
  match m:
    case None{{}}: Empty.absurd({{{CK("bs")} == {TRUE}}}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{{+ps}}: pv_r(ps, items, em, w, bs, Layout.encoding(ps), {{==}}, e)
def pv(+v: S.Value, +bs: +List<U32>, +e: {{Codec.encoding_for_legal_type(Spec.{X}(), v) == Some{{bs}} : Maybe<&2, +List<U32>>}})
    -> {{{CK("bs")} == {TRUE}}}:
  match v:
    case S.Sequence{{+items}}: pv_m(items, Codec.parts(items, {chain(0)}), {{==}}, SS.fixed_size({chain(0)}), bs, e)
{ABS()}
def c0id(+c: Bool, buf: B.Buf, +off: U32) -> {{T.{p}_c0(c, buf, off) == (buf, c) : B.Buf & Bool}}:
  match c:
    case True{{}}: {{==}}
    case False{{}}: {{==}}

def {X}_at({sig})
    -> {{T.{p}_ok_at({BF}, off) == ({BF}, {CK(W)}) : B.Buf & Bool}}:
  +hk = FD.nat__lt_le_trans(Nat.add(x, {K}n), Nat.add(x, {N}n), {P}, FD.nat__lt_add_left({K}n, {N}n, x, {{==}}), hb)
  +hy = FD.logic__subst(Nat, z => {{Nat.is_lt(z, {P}) == {TRUE}}}, Nat.add(x, {K}n), {y}, FD.nat__add_comm(x, {K}n), hk)
  +ey = UR.offx(d, off, {K}, x, e, FD.nat__lt_trans(d, 28n, 30n, hd, {{==}}), hy)
  %Equal.sym(B.Buf & Bool, O.ok_bool({BF}, U32.add(off, {K})), ({BF}, U32.is_le(VRB.BX(t, {y}), 1)), VRB.okb(d, t, n, U32.add(off, {K}), {y}, ey, hd, pf, hy)) :
    {{T.{p}_v0(off, _) == ({BF}, {CK(W)}) : B.Buf & Bool}}
  %Equal.sym(B.Buf & Bool, T.{p}_c0(U32.is_le(VRB.BX(t, {y}), 1), {BF}, off), ({BF}, U32.is_le(VRB.BX(t, {y}), 1)), c0id(U32.is_le(VRB.BX(t, {y}), 1), {BF}, off)) :
    {{_ == ({BF}, {CK(W)}) : B.Buf & Bool}}
  %Equal.sym(U32, VBL.nthb({W}, {K}n), VBL.nthb(UA.BYT(t), Nat.add(x, {K}n)),
      Equal.trans(U32, VBL.nthb({W}, {K}n), VBL.nthb(VS.bdr(x, UA.BYT(t)), {K}n), VBL.nthb(UA.BYT(t), Nat.add(x, {K}n)),
        VR.nth_bt({N}n, VS.bdr(x, UA.BYT(t)), {K}n, {{==}}), VR.nth_bdr(x, UA.BYT(t), {K}n))) :
    {{({BF}, U32.is_le(VRB.BX(t, {y}), 1)) == ({BF}, U32.is_le(_, 1)) : B.Buf & Bool}}
  %Equal.sym(Nat, Nat.add(x, {K}n), {y}, FD.nat__add_comm(x, {K}n)) :
    {{({BF}, U32.is_le(VRB.BX(t, {y}), 1)) == ({BF}, U32.is_le(VBL.nthb(UA.BYT(t), _), 1)) : B.Buf & Bool}}
  {{==}}

def {X}_okl({sig}, +b: Bool)
    -> {{T.{p}_ok_len(b, {BF}, off) == ({BF}, Bool.and(b, {CK(W)})) : B.Buf & Bool}}:
  match b:
    case True{{}}: {X}_at({args})
    case False{{}}: {{==}}

# the validator returns the length check and the slashed byte's check
def {X}_ok_eval({sig}, +len: U32)
    -> {{T.{p}_ok({BF}, off, len) == ({BF}, Bool.and(U32.is_eq(len, {N}), {CK(W)})) : B.Buf & Bool}}:
  {X}_okl({args}, U32.is_eq(len, {N}))

def {X}_rj(+bs: +List<U32>, +h: {{Bool.and(Nat.is_eq(List.length(&2, U32, bs), {N}n), {CK("bs")}) == False{{}} : Bool}}, +v: S.Value,
    +e: {{Codec.encoding_for_legal_type(Spec.{X}(), v) == Some{{bs}} : Maybe<&2, +List<U32>>}}) -> Empty:
  VRB.chk_true(Nat.is_eq(List.length(&2, U32, bs), {N}n), {CK("bs")},
    VRB.len_eq(SS.fixed_size(Spec.{X}()), {N}n, bs, Codec.parts(v, Spec.{X}()), DS.facts(v, Spec.{X}(), {{==}}), {{==}}, e), pv(v, bs, e), h)

# a byte list of another length, or whose slashed byte is above 1, is no encoding
def {X}_decode_reject(+bs: +List<U32>, +h: {{Bool.and(Nat.is_eq(List.length(&2, U32, bs), {N}n), {CK("bs")}) == False{{}} : Bool}}) -> Decoding.outside_image(Spec.{X}(), bs):
  v => e => {X}_rj(bs, h, v, e)
''')
    head = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', 'import ../../types/fulu_obj.bend as T',
            'import ../../types/schema.bend as S', 'import ../../spec/codec.bend as Codec', 'import ../../spec/layout.bend as Layout',
            'import ../../spec/primitives.bend as SP', 'import ../../spec/nat_bytes.bend as N', 'import ../../spec/decoding_relation.bend as Decoding',
            'import ../../spec/schema.bend as SS', 'import ../../proofs/decode_shape.bend as DS', 'import ../../proofs/decode_facts.bend as DF',
            'import ../../spec/fulu_schemas.bend as Spec', 'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A',
            'import ./vbuf.bend as VB', 'import ./vspec.bend as VS', 'import ./vbrt.bend as VR', 'import ./vbitl.bend as VBL', 'import ./vua.bend as UA',
            'import ./vua_rd.bend as UR', 'import ./vua_win.bend as UW', 'import ./vrejb.bend as VRB', '',
            '# GENERATED by fix_reject_chk (codegen). Do not edit.', '# Validator: ok_eval and decode_reject (its slashed byte at 88 is a boolean).', '']
    return _with_deep(X, '\n'.join(head + L) + '\n', 'validator') 


if __name__ == '__main__':
    main()
