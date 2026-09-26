#!/usr/bin/env python3
"""ok_eval and decode_reject for the fixed-size names whose validator also checks bytes:
booleans (O.ok_bool) and vectors of booleans (every byte at most 1).

    python3 codegen/fix_reject_chk.py [--check] [--no-big]

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
reads) are proved once in proofs/obj/vrejb.bend (from codegen/vrejb.bend.in); the names come
from the runtime (types/*_obj.bend: a validator O.ok_bool, or <p>_ok_n over O.ok_bool).
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))
TRUE = 'True{} : Bool'
P = 'A.quad(VB.pw(d))'


def rows():
    import schema
    import generic
    fulu = list(schema.load(ROOT / 'codegen/fulu.yaml'))
    gen = [n for n, t, e in generic.inventory_all() if e is None]
    out = []
    for f, tag in (('types/fulu_obj.bend', 'f'), ('types/generic_obj.bend', 'g')):
        src = (ROOT / f).read_text()
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
    return '\n'.join(L)


def module(tag, rs):
    T = '../../types/fulu_obj.bend' if tag == 'f' else '../../types/generic_obj.bend'
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import {T} as T',
         'import ../../types/schema.bend as S', 'import ../../spec/codec.bend as Codec', 'import ../../spec/decoding_relation.bend as Decoding',
         'import ../../spec/schema.bend as SS', 'import ../../proofs/decode_shape.bend as DS',
         'import ../../spec/fulu_schemas.bend as Spec' if tag == 'f' else 'import ./generic_specs.bend as GS',
         'import ../compact/found.bend as FD', 'import ../compact/arith.bend as A', 'import ./vbuf.bend as VB', 'import ./vua.bend as UA',
         'import ./vua_win.bend as UW', 'import ./vua_fix.bend as VTX', 'import ./vrl.bend as VRL', 'import ./vrejb.bend as VRB', '',
         '# GENERATED by codegen/fix_reject_chk.py. Do not edit.',
         '# Fixed-size names whose validator checks boolean bytes: ok_eval and decode_reject (see the generator).', '']
    for r in rs:
        L.append(name_text(*r))
    return '\n'.join(L) + '\n'


def outputs():
    rs = rows()
    out = {ROOT / 'proofs/obj/vrejb.bend': (ROOT / 'codegen/vrejb.bend.in').read_text()}
    for tag in ('f', 'g'):
        sub = [r for r in rs if r[1] == tag]
        if sub:
            out[ROOT / f'proofs/obj/fixchk_bool{tag}.bend'] = module(tag, sub)
    return out


def main():
    out = outputs()
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale: ' + ', '.join(stale))
            sys.exit(1)
        print('boolean-check reject laws are current')
        return
    for p, t in out.items():
        p.write_text(t)
    print(f'{len(out)} files: ' + ', '.join(r[0] for r in rows()))


if __name__ == '__main__':
    main()
