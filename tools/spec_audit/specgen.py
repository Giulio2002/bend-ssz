#!/usr/bin/env python3
"""Generate small Bend proofs by computation of the SPECIFICATION definitions (spec/*.bend) from the reference port.

    python3 tools/spec_audit/specgen.py --repo . --cs ../cs --cases DIR/cases.jsonl --out tools/spec_audit/spec_cases

Each emitted file holds independent `def cN() -> {f(args) == expected : T}: {==}` statements. The checker evaluates `f` on
the spec definitions and accepts only if it reduces to the reference value. Run each file with tools/check.sh (a few
seconds each). Groups:
  ser_*    spec/codec.bend encoding_for_legal_type(schema, value) == Some(reference bytes)   (accepted values)
  serneg_* the same function returns None for out-of-domain values (limit+1, wrong vector length, uint out of range, bad selector)
  dec_*    the computable decoders: boolean_decoding, uint_decoding, bitvector/bitlist_deserialize, vector/byte-list decoding
  lay_*    spec/layout_decoding.bend decoding(widths, bytes): the fixed/variable layout rules (first offset, order, range, tail)
  root_*   the Merkleization building blocks on the reference's chunks: limit-based depth, zero padding, mix_in_length/selector
"""
import argparse
import json
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import ssz_ref as S  # noqa: E402
from constants import ref_generic  # noqa: E402
from refparse import Ref  # noqa: E402

HDR = '''import Base
import ../../../types/schema.bend as T
import ../../../types/primitive.bend as P
import ../../../spec/codec.bend as Codec
import ../../../spec/primitives.bend as Prim
import ../../../spec/bit_decode.bend as BitDec
import ../../../spec/bytes.bend as Bytes
import ../../../spec/byte_list.bend as ByteList
import ../../../spec/bit_root.bend as BitRoot
import ../../../spec/byte_root.bend as ByteRoot
import ../../../spec/layout_decoding.bend as Lay
import ../../../spec/limits.bend as Limits
import ../../../spec/progressive.bend as Prog
import ../../../spec/mixing.bend as Mix
import ../../../spec/packing.bend as Pack
import ../../../proofs/obj/generic_specs.bend as G
import ../../../spec/fulu_schemas.bend as F
'''
MB = 'Maybe<&2, %s>'
BYTES = '+List<U32>'


def lst(xs):
    return '[' + ', '.join(str(x) for x in xs) + ']'


def bits_lit(bs):
    return '[' + ', '.join('True{}' if b else 'False{}' for b in bs) + ']'


def value_term(t, v):
    k = t[0]
    if k == 'bool':
        return 'T.BooleanValue{%s}' % ('True{}' if v else 'False{}')
    if k == 'uint':
        return 'T.UnsignedValue{%s}' % uint_term(v)
    if k in ('bytes', 'bytelist'):
        return 'T.BytesValue{%s}' % lst(list(v))
    if k in ('bitvector', 'bitlist', 'progbits'):
        return 'T.BitsValue{%s}' % bits_lit(v)
    if k in ('vector', 'list', 'proglist'):
        return 'T.Sequence{%s}' % items([t[1]] * len(v), v)
    if k in ('container', 'progcontainer'):
        return 'T.Sequence{%s}' % items([ft for _, ft in t[1]], v)
    if k == 'union':
        sel, val = v
        return 'T.Selected{%d, %s}' % (sel, 'T.NullValue{}' if t[1][sel] == ('null',) else value_term(t[1][sel], val))
    if k == 'compatunion':
        sel, val = v
        return 'T.Selected{%d, %s}' % (sel, value_term(t[2][t[1].index(sel)], val))
    raise ValueError(k)


def uint_term(v):
    return 'P.UInt{%s}' % ', '.join(str((v >> (32 * i)) & 0xFFFFFFFF) for i in range(8))


def items(ets, vs):
    out = 'T.EmptyItems{}'
    for et, v in reversed(list(zip(ets, vs))):
        out = 'T.Items{%s, %s}' % (value_term(et, v), out)
    return out


def vt(name, t):
    """The generic vec_uint8_N schemas are Vector[uint8] (a sequence of uint8 values), not ByteVector (T.BytesValue)."""
    return ('vector', ('uint', 8), t[1]) if name.startswith('vec_uint8_') and t[0] == 'bytes' else t


WIDTH = {8:'P.U8{}', 16: 'P.U16{}', 32: 'P.U32Width{}', 64: 'P.U64{}', 128: 'P.U128{}', 256: 'P.U256{}'}


class Out:
    def __init__(self, outdir, prefix, per_file=25, maxw=5000):
        self.dir, self.prefix, self.per, self.maxw, self.n, self.files, self.buf, self.w = outdir, prefix, per_file, maxw, 0, 0, [], 0

    def add(self, stmt):
        self.buf.append(stmt)
        self.n += 1
        self.w += len(stmt)
        if len(self.buf) >= self.per or self.w > self.maxw:      # bound the work per file: the checker evaluates every statement
            self.flush()

    def flush(self):
        if not self.buf:
            return
        name = '%s_%02d.bend' % (self.prefix, self.files)
        with open(os.path.join(self.dir, name), 'w') as f:
            f.write(HDR + '\n' + '\n'.join(self.buf))
        self.files += 1
        self.buf, self.w = [], 0


def stmt(i, expr, expected, ty):
    return 'def c%d() -> {%s == %s : %s}:\n  {==}\n' % (i, expr, expected, ty)


def schema_ref(name, src):
    return ('F.%s()' if src == 'fulu' else 'G.%s()') % name


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cs', required=True)
    ap.add_argument('--cases', required=True)
    ap.add_argument('--out', required=True)
    ap.add_argument('--seed', type=int, default=7)
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    ref, gen = Ref(a.cs), ref_generic(a.cs)
    fulu = json.load(open(os.path.join(a.repo, 'types/obj_groups.json')))
    gidx = json.load(open(os.path.join(a.repo, 'types/generic_obj_index.json')))['generated']
    rng = random.Random(a.seed)

    def nf_of(name):
        return ref.type_of(name) if name in fulu else gen[name][0]

    # a corpus sample per type
    by = {}
    for line in open(a.cases):
        c = json.loads(line)
        if c['hex'] is None or c['len'] > 400:
            continue
        by.setdefault(c['type'], []).append(c)

    ser = Out(a.out, 'ser', per_file=12, maxw=2500)
    neg, dec, lay = (Out(a.out, p) for p in ('serneg', 'dec', 'lay'))
    root = Out(a.out, 'root', per_file=2)
    counts = {}

    # ---------------- ser: accepted corpus cases of small types
    names = sorted(by)
    for name in names:
        t = nf_of(name)
        src = 'fulu' if name in fulu else 'generic'
        acc = [c for c in by[name] if c['verdict'] == 'accept' and c['len'] <= 160]
        rng.shuffle(acc)
        take = acc[:8] if src == 'generic' else acc[:3]
        for c in take:
            data = bytes.fromhex(c['hex'])
            v = S.deserialize(t, data)
            ser.add(stmt(ser.n, 'Codec.encoding_for_legal_type(%s, %s)' % (schema_ref(name, src), value_term(vt(name, t), v)), 'Some{%s}' % lst(list(data)), MB % BYTES))
    # ---------------- serneg: out-of-domain values -> None
    for name in names:
        t = nf_of(name)
        src = 'fulu' if name in fulu else 'generic'
        sch = schema_ref(name, src)
        k = t[0]
        if k in ('list', 'bytelist', 'bitlist') and t[-1] <= 40:
            v = {'bytelist': lambda: bytes(t[1] + 1), 'bitlist': lambda: [False] * (t[1] + 1), 'list': lambda: [S.zero_value(t[1])] * (t[2] + 1)}[k]()
            neg.add(stmt(neg.n, 'Codec.encoding_for_legal_type(%s, %s)' % (sch, value_term(vt(name, t), v)), 'None{}', MB % BYTES))
            v = {'bytelist': lambda: bytes(t[1]), 'bitlist': lambda: [True] * (t[1]), 'list': lambda: [S.zero_value(t[1])] * (t[2])}[k]()
            if len(value_term(vt(name, t), v)) < 3000:
                ok = S.serialize(t, v)
                neg.add(stmt(neg.n, 'Codec.encoding_for_legal_type(%s, %s)' % (sch, value_term(vt(name, t), v)), 'Some{%s}' % lst(list(ok)), MB % BYTES))
        if k in ('vector', 'bytes', 'bitvector') and (t[1] if k != 'vector' else t[2]) <= 40:
            n = t[1] if k != 'vector' else t[2]
            for m in (n - 1, n + 1):
                if m < 0:
                    continue
                v = {'bytes': lambda: bytes(m), 'bitvector': lambda: [False] * m, 'vector': lambda: [S.zero_value(t[1])] * m}[k]()
                neg.add(stmt(neg.n, 'Codec.encoding_for_legal_type(%s, %s)' % (sch, value_term(vt(name, t), v)), 'None{}', MB % BYTES))
        if k == 'uint' and t[1] < 256:
            neg.add(stmt(neg.n, 'Codec.encoding_for_legal_type(%s, T.UnsignedValue{%s})' % (sch, uint_term(1 << t[1])), 'None{}', MB % BYTES))
            neg.add(stmt(neg.n, 'Codec.encoding_for_legal_type(%s, T.UnsignedValue{%s})' % (sch, uint_term((1 << t[1]) - 1)),
                         'Some{%s}' % lst([255] * (t[1] // 8)), MB % BYTES))
        if k == 'compatunion':
            for sel in (0, max(t[1]) + 1, 128, 255):
                neg.add(stmt(neg.n, 'Codec.encoding_for_legal_type(%s, T.Selected{%d, T.NullValue{}})' % (sch, sel), 'None{}', MB % BYTES))
    # ---------------- dec: computable decoders
    for name in names:
        t = nf_of(name)
        cs = [c for c in by[name] if c['len'] <= 80]
        rng.shuffle(cs)
        k = t[0]
        if k not in ('bool', 'uint', 'bitvector', 'bitlist', 'bytes'):
            continue
        for c in cs[:10]:
            data = list(bytes.fromhex(c['hex']))
            try:
                v = S.deserialize(t, bytes(data))
            except S.Reject:
                v = None
            if k == 'bool':
                e, ex, ty = 'Prim.boolean_decoding(%s)' % lst(data), ('None{}' if v is None else 'Some{%s}' % ('True{}' if v else 'False{}')), MB % 'Bool'
            elif k == 'uint':
                e, ex, ty = 'Prim.uint_decoding(%s, %s)' % (WIDTH[t[1]], lst(data)), ('None{}' if v is None else 'Some{%s}' % uint_term(v)), MB % 'P.UInt'
            elif k == 'bitvector':
                e, ex, ty = 'BitDec.bitvector_deserialize(%dn, %s)' % (t[1], lst(data)), ('None{}' if v is None else 'Some{%s}' % bits_lit(v)), MB % '+List<Bool>'
            elif k == 'bitlist':
                e, ex, ty = 'BitDec.bitlist_deserialize(%dn, %s)' % (t[1], lst(data)), ('None{}' if v is None else 'Some{%s}' % bits_lit(v)), MB % '+List<Bool>'
            else:
                e, ex, ty = 'Bytes.vector_decoding(%dn, %s)' % (t[1], lst(data)), ('None{}' if v is None else 'Some{%s}' % lst(list(v))), MB % BYTES
            dec.add(stmt(dec.n, e, ex, ty))
    for cap in (1, 2, 31, 32, 33):               # byte lists: not a name of the suites, the decoder's limit and domain at the boundary
        for n in (0, 1, cap - 1, cap, cap + 1):
            if n < 0:
                continue
            data = [(i * 37 + 5) % 256 for i in range(n)]
            dec.add(stmt(dec.n, 'ByteList.decoding(%dn, %s)' % (cap, lst(data)), ('Some{%s}' % lst(data)) if n <= cap else 'None{}', MB % BYTES))
    dec.add(stmt(dec.n, 'Bytes.vector_decoding(2n, [1, 256])', 'None{}', MB % BYTES))   # a byte value out of 0..255
    dec.add(stmt(dec.n, 'BitDec.bitlist_deserialize(8n, [1, 1000])', 'None{}', MB % '+List<Bool>'))
    # ---------------- lay: container layout rules
    for name in names:
        t = nf_of(name)
        if t[0] not in ('container', 'progcontainer') or not S.is_variable_size(t):
            continue
        fts = [ft for _, ft in t[1]]
        if len(fts) > 12:
            continue
        widths = '[' + ', '.join('None{}' if S.is_variable_size(ft) else 'Some{%dn}' % S.fixed_size(ft) for ft in fts) + ']'
        cs = [c for c in by[name] if c['len'] <= 220]
        rng.shuffle(cs)
        rej = [c for c in cs if c['verdict'] == 'reject'][:14]
        acc = [c for c in cs if c['verdict'] == 'accept'][:5]
        for c in acc + rej:
            data = bytes.fromhex(c['hex'])
            try:
                sl = S.layout(fts, data)
                ex = 'Some{[%s]}' % ', '.join(lst(list(x)) for x in sl)
            except S.Reject:
                ex = 'None{}'
            lay.add(stmt(lay.n, 'Lay.decoding(%s, %s)' % (widths, lst(list(data))), ex, MB % '+List<+List<U32>>'))
    # ---------------- root: Merkleization building blocks, boundary limits
    def chunks_lit(chs):
        return '[' + ', '.join(lst(list(c)) for c in chs) + ']'
    HL = '+List<U32>'
    # ByteList / Bitlist / ByteVector / Bitvector roots at the limit
    for cap in (1, 31, 32, 33, 64, 65):
        depth = max(0, (((cap + 31) // 32) - 1).bit_length())
        for n in sorted({0, 1, cap - 1, cap, cap + 1}):
            if n < 0:
                continue
            data = bytes((i * 11 + 1) % 256 for i in range(n))
            exp = S.hash_tree_root(('bytelist', cap), data).hex() if n <= cap else None
            root.add(stmt(root.n, 'ByteList.at_depth(%dn, %dn, %s)' % (cap, depth, lst(list(data))), 'None{}' if exp is None else 'Some{%s}' % lst(list(bytes.fromhex(exp))), MB % HL))
    for cap in (1, 8, 255, 256, 257, 512, 513):
        depth = max(0, (((cap + 255) // 256) - 1).bit_length())
        for n in sorted({0, 1, cap - 1, cap, cap + 1}):
            if n < 0 or n > 600:
                continue
            bits = [(i * 7 + 3) % 5 < 2 for i in range(n)]
            exp = S.hash_tree_root(('bitlist', cap), bits) if n <= cap else None
            root.add(stmt(root.n, 'BitRoot.bitlist_at_depth(%dn, %dn, %s)' % (cap, depth, bits_lit(bits)), 'None{}' if exp is None else 'Some{%s}' % lst(list(exp)), MB % HL))
    for n in (1, 7, 8, 9, 255, 256, 257, 512, 513):
        depth = max(0, (((n + 255) // 256) - 1).bit_length())
        bits = [(i * 5 + 1) % 3 == 0 for i in range(n)]
        root.add(stmt(root.n, 'BitRoot.bitvector_at_depth(%dn, %dn, %s)' % (n, depth, bits_lit(bits)), 'Some{%s}' % lst(list(S.hash_tree_root(('bitvector', n), bits))), MB % HL))
        root.add(stmt(root.n, 'BitRoot.bitvector_at_depth(%dn, %dn, %s)' % (n, depth, bits_lit(bits + [False])), 'None{}', MB % HL))
    for n in (1, 31, 32, 33, 48, 64, 65):
        depth = max(0, (((n + 31) // 32) - 1).bit_length())
        data = bytes((i * 13 + 2) % 256 for i in range(n))
        root.add(stmt(root.n, 'ByteRoot.at_depth(%dn, %dn, %s)' % (n, depth, lst(list(data))), 'Some{%s}' % lst(list(S.hash_tree_root(('bytes', n), data))), MB % HL))
    # limit-based depth: container-style merkleize(chunks, limit)
    for limit in (0, 1, 2, 3, 4, 5, 8, 9):
        depth = 0 if limit <= 1 else (limit - 1).bit_length()
        for n in sorted({0, 1, limit - 1, limit, limit + 1}):
            if n < 0 or n > 10:
                continue
            chs = [bytes([i + 1] * 32) for i in range(n)]
            exp = S.merkleize(chs, limit) if n <= limit else None
            root.add(stmt(root.n, 'Limits.at_depth(%dn, %dn, %s)' % (limit, depth, chunks_lit(chs)), 'None{}' if exp is None else 'Some{%s}' % lst(list(exp)), MB % HL))
    # progressive merkleization at the growth boundaries 1, 4, 16 (and the empty case)
    for n in (0, 1, 2, 4, 5, 6, 21):
        chs = [bytes([i + 1] * 32) for i in range(n)]
        root.add(stmt(root.n, 'Prog.merkleize(%s)' % chunks_lit(chs), 'Some{%s}' % lst(list(S.merkleize_progressive(chs))), MB % HL))
    # selector / length mixing
    r0 = bytes(range(32))
    for sel in (0, 1, 127, 128, 255, 256):
        exp = S.mix_in_selector(r0, sel) if sel < 256 else None
        root.add(stmt(root.n, 'Mix.mix_in_selector(%s, %d)' % (lst(list(r0)), sel), 'None{}' if exp is None else 'Some{%s}' % lst(list(exp)), MB % HL))
    root.add(stmt(root.n, 'Mix.mix_in_length(%s, %s)' % (lst(list(r0)), uint_term(1000)), 'Some{%s}' % lst(list(S.mix_in_length(r0, 1000))), MB % HL))
    root.add(stmt(root.n, 'Mix.mix_in_selector(%s, 0)' % lst(list(bytes(32))), 'Some{%s}' % lst(list(S.hash_tree_root(('union', (('null',), ('uint', 8))), (0, None)))), MB % HL))
    # ---------------- uni: plain Unions (no Fulu or generic type is one, so the corpus has none): selector byte, None, bounds
    uni = Out(a.out, 'uni')
    u3 = 'T.Union{T.Chain{T.Null{}, T.Chain{T.Unsigned{P.U64{}}, T.Chain{T.Unsigned{P.U32Width{}}, T.End{}}}}}'        # Union[None, uint64, uint32]
    enc = lambda sch, val: 'Codec.encoding_for_legal_type(%s, %s)' % (sch, val)
    u64 = lambda v: 'T.UnsignedValue{%s}' % uint_term(v)
    cases = [
        (enc(u3, 'T.Selected{0, T.NullValue{}}'), 'Some{[0]}'),
        (enc(u3, 'T.Selected{1, %s}' % u64(5)), 'Some{[1, 5, 0, 0, 0, 0, 0, 0, 0]}'),
        (enc(u3, 'T.Selected{2, %s}' % u64(7)), 'Some{[2, 7, 0, 0, 0]}'),
        (enc(u3, 'T.Selected{2, %s}' % u64(1 << 32)), 'None{}'),                 # payload out of its uint32 range
        (enc(u3, 'T.Selected{3, %s}' % u64(7)), 'None{}'),                       # selector beyond the options
        (enc(u3, 'T.Selected{0, %s}' % u64(7)), 'None{}'),                       # None carries no payload
        (enc(u3, 'T.Selected{1, T.NullValue{}}'), 'None{}'),
        (enc(u3, 'T.Selected{255, T.NullValue{}}'), 'None{}'),
    ]
    ub = 'T.Union{' + ''.join('T.Chain{T.Boolean{}, ' for _ in range(128)) + 'T.End{}' + '}' * 128 + '}'              # 128 options: selectors 0..127
    cases += [(enc(ub, 'T.Selected{127, T.BooleanValue{True{}}}'), 'Some{[127, 1]}'), (enc(ub, 'T.Selected{128, T.BooleanValue{True{}}}'), 'None{}'),
              (enc(ub, 'T.Selected{0, T.BooleanValue{False{}}}'), 'Some{[0, 0]}')]
    uv = 'T.Union{T.Chain{T.ByteList{3n}, T.Chain{T.Vector{T.Boolean{}, 2n}, T.End{}}}}'                              # variable and fixed options: still [selector] ++ payload
    cases += [(enc(uv, 'T.Selected{0, T.BytesValue{[9, 8]}}'), 'Some{[0, 9, 8]}'), (enc(uv, 'T.Selected{0, T.BytesValue{[]}}'), 'Some{[0]}'),
              (enc(uv, 'T.Selected{0, T.BytesValue{[1, 2, 3, 4]}}'), 'None{}'),
              (enc(uv, 'T.Selected{1, T.Sequence{T.Items{T.BooleanValue{True{}}, T.Items{T.BooleanValue{False{}}, T.EmptyItems{}}}}}'), 'Some{[1, 1, 0]}')]
    for e, x in cases:
        uni.add(stmt(uni.n, e, x, MB % BYTES))
    for o in (ser, neg, dec, lay, root, uni):
        o.flush()
    print(json.dumps({o.prefix: o.n for o in (ser, neg, dec, lay, root, uni)}))


if __name__ == '__main__':
    main()
