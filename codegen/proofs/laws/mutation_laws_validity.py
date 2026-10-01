#!/usr/bin/env python3
"""Laws that pin the validity checks of the encoders (docs/MUTATION_PROOFS.md, group "validity-check").

    python3 codegen/proofs/laws/mutation_laws_validity.py [--check]

The checked serializer of every name is `X_ser_pick(P_valid(o), o)` (a Data object) or a pass that threads the
storage (words and bits). The existing laws say what follows from `P_valid(o) == True` and from `== False`; none says
when the validity pass is one or the other, so a changed bound, a forced result or a wrong poison flag was invisible.
For every name this file writes, into proofs/obj/mutval_<runtime>_<X>.bend (one file per name: a facade
imports and re-checks only its own),

  <X>_serialize_vdom(o)         a Data name: `X_serialize(o) == X_ser_pick(DOM(o), o)`, DOM the schema's domain written out:
                                `True{}` (every object is valid: bool, uint32 and wider, byte vectors, fixed containers of
                                these), `U32.is_le(o, 255)` / `65535` (uint8, uint16), `U32.is_lt(w, 256)` (Bytes1),
                                `U32.is_lt(w_last, 2^(k mod 32))` (a bit vector of k bits: the bits past k are zero).
                                The domain comes from the schema (codegen/fulu.yaml, the generic inventory), not from the
                                generated check; the generator stops if they disagree.
  <X>_serialize_vin[_n]()       a words or bits name: the serializer of an object at the accepted edge (n bytes or bits:
                                the vector's exact length, 0 and one element for a list, the limit for a bit list) is its
                                encoding. Fails when the lower bound, the unit, the poison flag or the bits-past-the-end
                                rule is wrong.
  <X>_serialize_vover()         the serializer of an object one past the limit is refused. Fails when the upper bound or the
                                unbounded flag is wrong.

The storage of the objects is a concrete zero array with room (the check reads the storage's size, so a variable one
would leave it stuck); that bounds the edges that can be stated: nothing above IN_MAX bytes or bits is (Blob's
131072-byte encoding did not check in 600 s; a list limit of 2^30 would need 2^28 words). Byte vectors that
codegen/proofs/laws/mutation_laws.py already covers are skipped. Every statement is by computation.
They are named so that api_gate files them under serialize_valid, so they reach each name's
proofs/api/<X>_encode_ssz_proof_generated.bend.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import writer  # noqa: E402
from codegen.core import schema, generic  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402
from codegen.proofs.collections.laws import qual  # noqa: E402
from codegen.core.paths import ROOT  # noqa: E402

IN_MAX = 16500  # bytes or bits an edge law computes whole (16416 bytes, vec_uint256_513, is the largest vector but Blob)
DATA = re.compile(r'^def (\w+)_serialize\(\+o: ([\w.]+)\) -> O\.Encoded: \1_ser_pick\((\w+)_valid\(o\), o\)$', re.M)
SER = re.compile(r'^def (\w+)_serialize\(o: (O\.Words|O\.Bits)\) -> [^\n]*: ([^\n]*)$', re.M)
WORDS = re.compile(r'^O\.words_ok\(o, (\d+), (\d+), (True|False)\{\}, (\d+)\)$')
BITS = re.compile(r'^O\.bits_ok\(o, (\d+), (True|False)\{\}\)$')


class Sink:
    """the lines of each name's laws, by name"""
    def __init__(self):
        self.X, self.by = None, {}

    def w(self, line):
        self.by.setdefault(self.X, []).append(line)


def storage(n_units, per_word):
    """a zero array with room for n_units (bytes or bits) and the word the check reads after them"""
    k = 0
    while (1 << k) < n_units // per_word + 2:
        k += 1
    return f'O.out_at({k}n)'


def schemas(runtime):
    if runtime == 'fulu':
        return dict(schema.load(ROOT / 'codegen/fulu.yaml'))
    return {n: t for n, t, e in generic.inventory_all() if t is not None}


def always_valid(t):
    """the schema's verdict: every representable object of the type is a valid value (nothing to range-check)"""
    if t.kind == 'bool':
        return True
    if t.kind == 'uint':
        return t.size >= 4
    if t.kind == 'bytes':
        return t.size != 1
    if t.kind == 'bits':
        return t.size % 32 == 0
    if t.kind == 'container':
        return all(always_valid(f) for _, f in t.fields)
    return False


def domain_laws(runtime, text, sink):
    sch = schemas(runtime)
    w = sink.w
    cnt = 0
    for X, R, P in DATA.findall(text):
        t = sch.get(X)
        if t is None:
            continue
        sink.X = X
        Rq = qual(R)
        vm = re.search(rf'^def {P}_valid\(\+?o: [\w.]+\) -> Bool: ([^\n]*)$', text, re.M)
        cm = re.search(rf'^def {P}_valid\(o: [\w.]+\) -> Bool:\n  match o:\n    case (\w+)\{{([^}}]*)\}}: U32\.is_lt\((\w+), (\d+)\)$', text, re.M)
        if vm and vm.group(1) == 'True{}':
            if not always_valid(t):
                raise SystemExit(f'mutation_laws_validity: {X}: the validity pass is `True{{}}`, the schema has a range ({t.kind} {t.size})')
            w(f'# ---- {X}: every object is valid ----')
            w(f'def {X}_serialize_vdom(+o: {Rq}) -> {{T.{X}_serialize(o) == T.{X}_ser_pick(True{{}}, o) : O.Encoded}}:')
            w('  {==}')
            cnt += 1
        elif vm and t.kind == 'uint' and t.size in (1, 2):
            K = (1 << (8 * t.size)) - 1
            if vm.group(1) != f'U32.is_le(o, {K})':
                raise SystemExit(f'mutation_laws_validity: {X}: the validity pass is `{vm.group(1)}`, the schema says at most {K}')
            w(f'# ---- {X}: valid exactly up to {K} ----')
            w(f'def {X}_serialize_vdom(+o: {Rq}) -> {{T.{X}_serialize(o) == T.{X}_ser_pick(U32.is_le(o, {K}), o) : O.Encoded}}:')
            w('  {==}')
            cnt += 1
        elif cm:
            con, fields, last, M = cm.group(1), cm.group(2), cm.group(3), int(cm.group(4))
            if t.kind == 'bytes' and t.size == 1:
                want = 256
            elif t.kind == 'bits' and t.size % 32:
                want = 1 << (t.size % 32)
            else:
                raise SystemExit(f'mutation_laws_validity: {X}: a range check the schema does not have')
            if M != want:
                raise SystemExit(f'mutation_laws_validity: {X}: the validity pass checks below {M}, the schema says {want}')
            fs = [f.strip().lstrip('+') for f in fields.split(',')]
            if fs[-1] != last:
                raise SystemExit(f'mutation_laws_validity: {X}: the range check is not on the last word')
            o = f'T.{con}{{{", ".join(fs)}}}'
            w(f'# ---- {X}: valid exactly when the last word is below {M} ----')
            w(f'def {X}_serialize_vdom({", ".join("+" + f + ": U32" for f in fs)}) -> {{T.{X}_serialize({o}) == T.{X}_ser_pick(U32.is_lt({last}, {M}), {o}) : O.Encoded}}:')
            w('  {==}')
            cnt += 1
    return cnt


def edge_laws(text, sink):
    w = sink.w
    cnt = 0
    for X, R, body in SER.findall(text):
        m = re.search(r'\b(\w+?)_(?:putk|size)\(', body)
        if not m:
            continue
        P = m.group(1)
        vm = re.search(rf'^def {P}_valid\(o: {re.escape(R)}\) -> [^\n:]*: ([^\n]*)$', text, re.M)
        if not vm or not re.search(rf'^def {X}_encode\(o: {re.escape(R)}\) -> ', text, re.M):
            continue
        v = vm.group(1)
        over = None
        if R == 'O.Words':
            wm = WORDS.match(v[len('O.bools_ok('):-1] if v.startswith('O.bools_ok(') else v)
            if not wm:
                continue
            lo, hi, big, unit = int(wm.group(1)), int(wm.group(2)), wm.group(3) == 'True', int(wm.group(4))
            if lo == hi and not big and unit == 1 and 0 < lo <= 4096 and not v.startswith('O.bools_ok('):
                continue  # a byte vector: codegen/proofs/laws/mutation_laws.py
            if lo > IN_MAX or (lo == hi and not big and hi > IN_MAX):
                continue
            ins = [lo] if lo else [0, unit]
            if not big and unit == 1 and hi <= IN_MAX:
                over = hi + 1
            per, unit_name = 4, 'bytes'
        else:
            bm = BITS.match(v)
            if not bm:
                continue
            lim, big = int(bm.group(1)), bm.group(2) == 'True'
            if lim > IN_MAX:
                continue
            ins = [lim] if not big else [1]
            if not big:
                over = lim + 1
            per, unit_name = 32, 'bits'
        sink.X = X
        for n_in in ins:
            o = f'{R}{{{storage(max(n_in, 1), per)}, {n_in}}}'
            e = f'T.{X}_encode({o})'
            tag = '' if len(ins) == 1 else f'_{n_in}'
            w(f'# ---- {X}: {n_in} {unit_name} is accepted ----')
            w(f'def {X}_serialize_vin{tag}() -> {{T.{X}_serialize({o}) == (Pair.fst({R}, B.Buf, {e}), O.encoded(Pair.snd({R}, B.Buf, {e}))) : {R} & O.Encoded}}:')
            w('  {==}')
            cnt += 1
        if over is not None:
            o = f'{R}{{{storage(over, per)}, {over}}}'
            w(f'# ---- {X}: {over} {unit_name} is refused ----')
            w(f'def {X}_serialize_vover() -> {{T.{X}_serialize({o}) == ({o}, O.refused()) : {R} & O.Encoded}}:')
            w('  {==}')
            cnt += 1
    return cnt


def module(runtime, tmod):
    text = RR.mono_text(runtime)
    sink = Sink()
    n = domain_laws(runtime, text, sink) + edge_laws(text, sink)
    head = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '',
            writer.header('mutation_laws_validity'),
            '# Laws that pin the validity checks of the encoders (found by mutation testing; docs/MUTATION_VALIDITY.md).',
            '# Each is by computation. One file per name: a facade imports (and re-checks) only its own.', '']
    return {X: '\n'.join(head + lines) + '\n' for X, lines in sink.by.items()}, n


def main():
    out, cnt = {}, []
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        files, n = module(runtime, tmod)
        for X, t in files.items():
            out[ROOT / f'proofs/obj/mutval_{runtime}_{X}.bend'] = t
        cnt.append(n)
    orphans = sorted(str(q.relative_to(ROOT)) for q in (ROOT / 'proofs/obj').glob('mutval_*.bend') if q not in out)
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale validity laws: ', 'validity laws are current', orphans)
    writer.write(out, orphans)
    print(f'{cnt} laws in {len(out)} files')


if __name__ == '__main__':
    main()
