#!/usr/bin/env python3
"""Object-level corpus: values the checked serializers must REFUSE (and boundary values they must accept), from the reference.

    python3 tools/spec_audit/invalid_cases.py --repo . --cs ../cs --out tools/spec_audit/data/invalid_cases.json

The differential corpus of cases.py starts from BYTES: it decodes them and re-encodes what was accepted, so every object the
Bend side ever serializes came out of a decoder and is valid. Code that only differs on invalid objects (the validity pass of
every `<Name>_serialize`: a uint8 above 255, padding bits of a bit vector, a list one element past its limit, a vector one
element short, a field of a container that is out of range, a union payload that is out of range, packed booleans other than
0 and 1, a collection whose storage cannot hold its length) is unreachable from bytes. This file lists such objects as
NEUTRAL values (plain numbers, bit lists, element lists, field maps) and asks the reference port (ssz_ref.serialize, strict:
LAX off) what it does: a value the port refuses must be refused by the Bend serializer; a value the port serializes must be
serialized to the same bytes. `run_invalid_cases.py` lowers every value to the raw record constructors of the compiled object
API (a state no decoder or checked setter produces), builds one Bend program for all of them and compares.

Neutral values (JSON):
    {"u": n}                                   an unsigned integer (uint8 .. uint32)
    {"bits": [0, 1, ...]}                      a bit vector / bit list value (a list longer or shorter than the type is invalid)
    {"elems": [..], "esize": 1|2}              a vector / list of uint8, uint16 or bool, one number per element
    {"rawbits": [w, ...], "k": n, "depth": d}  a bit list of n bits held in the 32-bit words w (the words past the length may carry
                                               stray bits); the storage has 2^d words
    {"rawwords": [w, ...], "len": n, "depth": d}  n bytes held in the words w, the storage has 2^d words
    {"items": n}                               a list of n default composite elements
    {"fields": {name: value}}                  a container: the named fields are replaced, the others stay zero
    {"union": [selector, value]}               a compatible union
A "raw" value is a representable state with no value of its own in the specification (stray bits past the length, bytes that are
not a whole number of elements, storage smaller than the length): the reference verdict for those is `refuse` by the rule that
an object the serializer cannot read back as exactly one specification value is not serializable (source: representation).

Every case: {id, class, type, value, verdict: refuse|accept, source: reference|representation, hex (accepted), root (accepted)}.
"""
import argparse
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import ssz_ref as S  # noqa: E402

U8, U16, U32, U64 = ('uint', 8), ('uint', 16), ('uint', 32), ('uint', 64)

# ---- the class table (what the case guards against) -------------------------------------------------------------------------
CLASSES = {
    'uint-range': 'a basic integer above its width (uint8 256 .. , uint16 65536 ..): validity bound of the scalar',
    'bit-padding': 'bits above the length of a bit vector (the padding of its last byte) and stray bits of a bit list between its length and its delimiter',
    'limit': 'a list or bit list one element past its limit, and a vector one element short or long: the validity bound at limit / limit + 1',
    'storage': 'a collection whose storage cannot hold its length, and a byte length that is not a whole number of elements',
    'field-validity': 'every field of a container, the field that is out of range among valid ones: the validity of the fields reaches the result',
    'union-payload': 'a union whose payload is invalid',
    'bool-bytes': 'a packed boolean vector holding a byte other than 0 and 1',
    'valid-bytes': 'valid objects at and next to the boundaries: the exact bytes of the serializer (offsets, lengths, padding)',
    'absent-box': 'a vector of variable-size elements whose boxes hold no value (the default object): not a value of the type',
}


def bits_of(n, ones=()):
    return [1 if i in ones else 0 for i in range(n)]


def pat(n, esize):
    """n elements: all distinct for a short list, zeros with a set first and last element for a long one (the expression stays small)"""
    top = 256 ** esize - 1
    if n <= 6:
        return [((i + 1) * 40503 + 17) % (top + 1) for i in range(n)]
    e = [0] * n
    e[0], e[-1] = 0x1234 & top, 0xABCD & top
    return e


def cases():
    out = []

    def add(cls, name, value, tag):
        out.append({'id': '%s/%s/%s' % (cls, name, tag), 'class': cls, 'type': name, 'value': value})

    # --- scalars
    for v in (256, 257, 300, 65535, 4294967295):
        add('uint-range', 'uint8', {'u': v}, str(v))
    for v in (0, 1, 127, 255):
        add('valid-bytes', 'uint8', {'u': v}, str(v))
    for v in (65536, 65537, 70000, 4294967295):
        add('uint-range', 'uint16', {'u': v}, str(v))
    for v in (0, 255, 256, 4660, 65535):
        add('valid-bytes', 'uint16', {'u': v}, str(v))
    # --- bit vectors: bits above the length
    for n, name in ((5, 'bitvector_5'), (9, 'bitvector_9')):
        for p in (n, n + 1, n + 3, 15):
            add('bit-padding', name, {'bits': bits_of(p + 1, {p})}, 'bit%d' % p)
        add('bit-padding', name, {'bits': [1] * 16}, 'all16')
        add('valid-bytes', name, {'bits': [1] * n}, 'ones')
        add('valid-bytes', name, {'bits': bits_of(n, {0, n - 1})}, 'ends')
        add('valid-bytes', name, {'bits': [0] * n}, 'zeros')
    # --- bit lists
    for extra in (1, 2, 3, 35):
        add('limit', 'bitlist_5', {'bits': bits_of(5 + extra, {5 + extra - 1})}, 'len%d' % (5 + extra))
        add('limit', 'bitlist_5', {'bits': [0] * (5 + extra)}, 'zeros%d' % (5 + extra))
    for k, ones in ((0, ()), (1, (0,)), (4, (1, 3)), (5, (0, 1, 2, 3, 4)), (5, ())):
        add('valid-bytes', 'bitlist_5', {'bits': bits_of(k, set(ones))}, 'len%d_%s' % (k, ''.join(map(str, ones)) or 'z'))
    for k, w in ((5, 32), (5, 33), (5, 64), (5, 1 << 31), (3, 8), (2, 4), (0, 1), (0, 2), (4, 16)):
        add('bit-padding', 'bitlist_5', {'rawbits': [w], 'k': k, 'depth': 3}, 'stray_k%d_w%d' % (k, w))
    for k, w in ((5, 31), (3, 7), (0, 0), (4, 15)):
        add('valid-bytes', 'bitlist_5', {'rawbits': [w], 'k': k, 'depth': 3}, 'clean_k%d_w%d' % (k, w))
    add('limit', 'bitlist_513', {'bits': [0] * 514}, 'len514')
    add('limit', 'bitlist_513', {'bits': [1] * 520}, 'len520')
    add('valid-bytes', 'bitlist_513', {'bits': [1] * 513}, 'len513')
    add('valid-bytes', 'bitlist_513', {'bits': [1] * 512}, 'len512')
    add('valid-bytes', 'bitlist_513', {'bits': bits_of(256, {255})}, 'len256')
    add('bit-padding', 'bitlist_513', {'rawbits': [0] * 16 + [64], 'k': 513, 'depth': 5}, 'stray_k513')
    add('storage', 'progbitlist', {'rawbits': [0], 'k': 100, 'depth': 0}, 'one_word_100_bits')
    add('storage', 'progbitlist', {'rawbits': [0], 'k': 32, 'depth': 0}, 'one_word_32_bits')
    add('storage', 'progbitlist', {'rawbits': [0, 0], 'k': 64, 'depth': 1}, 'two_words_64_bits')
    add('valid-bytes', 'progbitlist', {'rawbits': [0], 'k': 31, 'depth': 0}, 'one_word_31_bits')
    add('valid-bytes', 'progbitlist', {'rawbits': [5, 0], 'k': 63, 'depth': 1}, 'two_words_63_bits')
    add('valid-bytes', 'progbitlist', {'bits': [1] * 33}, 'len33')
    add('valid-bytes', 'progbitlist', {'bits': []}, 'empty')
    add('bit-padding', 'progbitlist', {'rawbits': [8], 'k': 3, 'depth': 3}, 'stray_k3')
    add('limit', 'FuluAttestation', {'fields': {'aggregation_bits': {'bits': [0] * 131073}}}, 'bits131073')
    add('limit', 'FuluAttestation', {'fields': {'aggregation_bits': {'bits': bits_of(131080, {0, 131079})}}}, 'bits131080')
    add('valid-bytes', 'FuluAttestation', {'fields': {'aggregation_bits': {'bits': bits_of(131072, {0, 131071})}}}, 'bits131072')
    add('valid-bytes', 'FuluAttestation', {'fields': {'aggregation_bits': {'bits': [1] * 5}}}, 'bits5')
    add('storage', 'FuluAttestation', {'fields': {'aggregation_bits': {'rawbits': [0], 'k': 131072, 'depth': 12}}}, 'bits131072_short_storage')
    add('storage', 'FuluAttestation', {'fields': {'aggregation_bits': {'rawbits': [0], 'k': 100000, 'depth': 10}}}, 'bits100000_short_storage')
    # --- vectors of uint16 / byte vectors / packed booleans
    for n in (0, 1, 4, 6, 11):
        add('limit', 'vec_uint16_5', {'elems': [(i + 1) * 257 for i in range(n)], 'esize': 2}, 'len%d' % n)
    for v in ([1, 2, 3, 4, 5], [0] * 5, [65535] * 5, [256, 255, 0, 1, 65280]):
        add('valid-bytes', 'vec_uint16_5', {'elems': v, 'esize': 2}, '_'.join(map(str, v)))
    for n in (9, 11, 12, 1, 3):
        add('storage', 'vec_uint16_5', {'rawwords': [16909060, 84281096, 134480385], 'len': n, 'depth': 2}, 'bytes%d' % n)
    for n in (0, 1, 2, 4, 5, 8):
        add('limit', 'vec_uint8_3', {'elems': list(range(1, n + 1)), 'esize': 1}, 'len%d' % n)
    for v in ([1, 2, 3], [255, 0, 128], [0, 0, 0]):
        add('valid-bytes', 'vec_uint8_3', {'elems': v, 'esize': 1}, '_'.join(map(str, v)))
    for n in (4, 5, 8):
        add('storage', 'vec_uint8_3', {'rawwords': [67305985, 5], 'len': n, 'depth': 1}, 'bytes%d' % n)
    for bad in range(5):
        for v in (2, 3, 255):
            e = [0] * 5
            e[bad] = v
            add('bool-bytes', 'vec_bool_5', {'elems': e, 'esize': 1}, 'pos%d_val%d' % (bad, v))
    for e in ([1, 0, 1, 0, 1], [0] * 5, [1] * 5, [0, 1, 0, 0, 0]):
        add('valid-bytes', 'vec_bool_5', {'elems': e, 'esize': 1}, ''.join(map(str, e)))
    # --- containers: every field, among valid ones
    def fv(name, fld, val, cls, tag):
        add(cls, name, {'fields': {fld: val}}, '%s_%s' % (fld, tag))

    for fld in ('A', 'B'):
        for v in (65536, 65537, 4294967295):
            fv('SmallTestStruct', fld, {'u': v}, 'field-validity', str(v))
        fv('SmallTestStruct', fld, {'u': 65535}, 'valid-bytes', '65535')
    add('valid-bytes', 'SmallTestStruct', {'fields': {'A': {'u': 4660}, 'B': {'u': 22136}}}, 'both')
    for v in (256, 300, 4294967295):
        fv('SingleFieldTestStruct', 'A', {'u': v}, 'field-validity', str(v))
        fv('ProgressiveSingleFieldContainerTestStruct', 'A', {'u': v}, 'field-validity', str(v))
        fv('FixedTestStruct', 'A', {'u': v}, 'field-validity', str(v))
    for v in (0, 255):
        fv('SingleFieldTestStruct', 'A', {'u': v}, 'valid-bytes', str(v))
        fv('ProgressiveSingleFieldContainerTestStruct', 'A', {'u': v}, 'valid-bytes', str(v))
        fv('FixedTestStruct', 'A', {'u': v}, 'valid-bytes', str(v))
    add('valid-bytes', 'FixedTestStruct', {'fields': {'A': {'u': 7}, 'C': {'u': 4294967295}}}, 'A7_Cmax')
    for fld, v in (('A', 65536), ('C', 256), ('A', 4294967295), ('C', 4294967295)):
        fv('VarTestStruct', fld, {'u': v}, 'field-validity', str(v))
    add('field-validity', 'VarTestStruct', {'fields': {'A': {'u': 65536}, 'C': {'u': 256}}}, 'A_and_C')
    for n in (1025, 1026, 2000):
        fv('VarTestStruct', 'B', {'elems': [0] * n, 'esize': 2}, 'limit', 'len%d' % n)
    for n in (3, 2049, 2051):
        fv('VarTestStruct', 'B', {'rawwords': [16909060] * 2, 'len': n, 'depth': 1}, 'storage', 'bytes%d_short' % n)
    for n in (1, 2049, 4097):
        fv('VarTestStruct', 'B', {'rawwords': [0] * 1024, 'len': n, 'depth': 10}, 'storage', 'bytes%d_odd' % n)
    for n in (0, 1, 3, 1023, 1024):
        fv('VarTestStruct', 'B', {'elems': pat(n, 2), 'esize': 2}, 'valid-bytes', 'len%d' % n)
    add('valid-bytes', 'VarTestStruct', {'fields': {'A': {'u': 4660}, 'B': {'elems': [43981, 1, 2], 'esize': 2}, 'C': {'u': 86}}}, 'mixed')
    add('valid-bytes', 'VarTestStruct', {'fields': {'A': {'u': 65535}, 'B': {'elems': [65535] * 7, 'esize': 2}, 'C': {'u': 255}}}, 'max')
    add('valid-bytes', 'VarTestStruct', {'fields': {'A': {'u': 1}, 'B': {'elems': [], 'esize': 2}, 'C': {'u': 2}}}, 'empty_b')
    # a byte list field and a uint16 list field inside the largest generic container
    for n in (257, 258, 300, 1000):
        fv('ComplexTestStruct', 'D', {'elems': [0] * n, 'esize': 1}, 'limit', 'bytes%d' % n)
    for n in (129, 130, 200):
        fv('ComplexTestStruct', 'B', {'elems': [0] * n, 'esize': 2}, 'limit', 'len%d' % n)
    for n in (0, 1, 255, 256):
        fv('ComplexTestStruct', 'D', {'elems': pat(n, 1), 'esize': 1}, 'valid-bytes', 'bytes%d' % n)
    for n in (0, 1, 127, 128):
        fv('ComplexTestStruct', 'B', {'elems': pat(n, 2), 'esize': 2}, 'valid-bytes', 'len%d' % n)
    fv('ComplexTestStruct', 'A', {'u': 65536}, 'field-validity', '65536')
    fv('ComplexTestStruct', 'C', {'u': 256}, 'field-validity', '256')
    add('absent-box', 'ComplexTestStruct', {'fields': {}, 'absent': True}, 'default_boxes')
    out[-1]['known'] = 'open finding: ComplexTestStruct_serialize accepts the default object (the vector of VarTestStruct holds absent boxes) and writes 14 bytes too few'
    for n in (3, 4, 5):
        fv('FuluExecutionRequests', 'consolidations', {'items': n}, 'limit', 'items%d' % n)
    for n in (0, 1, 2):
        fv('FuluExecutionRequests', 'consolidations', {'items': n}, 'valid-bytes', 'items%d' % n)
    for p, tag in ((256, '256'), (4294967295, 'max')):
        add('union-payload', 'CompatibleUnionA', {'union': [1, {'type': 'ProgressiveSingleFieldContainerTestStruct', 'fields': {'A': {'u': p}}}]}, 'payload_' + tag)
    for p in (0, 255):
        add('valid-bytes', 'CompatibleUnionA', {'union': [1, {'type': 'ProgressiveSingleFieldContainerTestStruct', 'fields': {'A': {'u': p}}}]}, 'payload_%d' % p)
    return out


# ---- the reference side -----------------------------------------------------------------------------------------------------

def ref_types(repo, cs):
    """name -> reference type (normal form of ssz_ref)"""
    sys.path.insert(0, HERE)
    from constants import ref_generic
    from refparse import Ref
    ref = Ref(cs)
    gen = ref_generic(cs)
    fork = json.load(open(os.path.join(repo, 'types/obj_groups.json')))
    t = {}
    simple = {'uint8': U8, 'uint16': U16, 'bitvector_5': ('bitvector', 5), 'bitvector_9': ('bitvector', 9),
              'bitlist_5': ('bitlist', 5), 'bitlist_513': ('bitlist', 513), 'progbitlist': ('progbits',),
              'vec_uint16_5': ('vector', U16, 5), 'vec_uint8_3': ('bytes', 3), 'vec_bool_5': ('vector', ('bool',), 5)}
    t.update(simple)
    for n in ('VarTestStruct', 'SmallTestStruct', 'SingleFieldTestStruct', 'ProgressiveSingleFieldContainerTestStruct', 'FixedTestStruct',
              'ComplexTestStruct', 'CompatibleUnionA'):
        t[n] = gen[n][0]
    for n in ('Attestation', 'ExecutionRequests'):
        assert n in fork, n
        t['Fulu' + n] = ref.type_of(n)
    return t


def field_index(t, name):
    return [f[0] for f in t[1]].index(name)




def compress(v):
    """a copy of a neutral value with long uniform lists written as a count and a fill ({"bitsn": n, "fill": b}, {"elemsn": n, "fill": x})"""
    if isinstance(v, dict):
        w = {k: compress(x) for k, x in v.items()}
        for key, cnt in (('bits', 'bitsn'), ('elems', 'elemsn')):
            if key in w and len(w[key]) > 16 and len(set(w[key])) == 1:
                w[cnt], w['fill'] = len(w[key]), w[key][0]
                del w[key]
        return w
    if isinstance(v, list):
        return [compress(x) for x in v]
    return v


def expand(v):
    """the inverse of compress"""
    if isinstance(v, dict):
        w = {k: expand(x) for k, x in v.items()}
        if 'bitsn' in w:
            w['bits'] = [w['fill']] * w.pop('bitsn')
            del w['fill']
        if 'elemsn' in w:
            w['elems'] = [w['fill']] * w.pop('elemsn')
            del w['fill']
        return w
    if isinstance(v, list):
        return [expand(x) for x in v]
    return v


def annotate(t, v):
    """add what the lowering needs: the position of every named field and the option index of a union selector"""
    if 'fields' in v:
        v['_idx'] = {k: field_index(t, k) for k in v['fields']}
        for k, x in v['fields'].items():
            annotate(t[1][field_index(t, k)][1], x)
    if 'union' in v:
        sel, payload = v['union']
        v['opt'] = t[1].index(sel)
        annotate(t[2][v['opt']], payload)


def ref_value(t, v):
    """the reference value of a neutral value, or None when it has no value of its own (a raw state)"""
    if 'u' in v:
        return v['u']
    if 'bits' in v:
        return list(v['bits'])
    if 'elems' in v:
        if t[0] == 'bytes' or t[0] == 'bytelist':
            return bytes(v['elems'])
        if t[0] == 'vector' and t[1] == ('bool',):
            return [bool(x) if x in (0, 1) else x for x in v['elems']]
        return list(v['elems'])
    if 'items' in v:
        et = t[1]
        return [S.zero_value(et) for _ in range(v['items'])]
    if 'fields' in v:
        z = S.zero_value(t)
        z = list(z)
        for k, fvv in v['fields'].items():
            i = field_index(t, k)
            z[i] = ref_value(t[1][i][1], fvv)
        return z
    if 'union' in v:
        sel, payload = v['union']
        opt = t[2][t[1].index(sel)]
        return (sel, ref_value(opt, payload))
    return None


def is_raw(v):
    if 'absent' in v:
        return True
    if 'rawbits' in v or 'rawwords' in v:
        return True
    if 'fields' in v:
        return any(is_raw(x) for x in v['fields'].values())
    if 'union' in v:
        return is_raw(v['union'][1])
    return False


def decide(c, types):
    t = types[c['type']]
    v = c['value']
    if is_raw(v):
        c['verdict'], c['source'] = None, 'representation'
        return c
    val = ref_value(t, v)
    try:
        s = S.serialize(t, val)
        c['verdict'], c['source'] = 'accept', 'reference'
        c['hex'] = s.hex()
        c['root'] = S.hash_tree_root(t, val).hex()
    except (AssertionError, OverflowError, ValueError, TypeError, IndexError) as e:
        c['verdict'], c['source'] = 'refuse', 'reference'
        c['reason'] = '%s: %s' % (type(e).__name__, e)
    return c


def raw_valid(c, types):
    """a raw value that is a clean representation of a specification value: the reference serializes that value"""
    v = c['value']
    t = types[c['type']]

    def to_plain(t, v):
        if 'absent' in v:
            return v, True
        if 'rawbits' in v:
            k = v['k']
            ws = v['rawbits']
            bits = [(ws[i // 32] >> (i % 32)) & 1 if i // 32 < len(ws) else 0 for i in range(k)]
            stray = [(ws[i // 32] >> (i % 32)) & 1 for i in range(k, 32 * len(ws))]
            return {'bits': bits}, any(stray) or (k // 32 + 1 > 2 ** v['depth'])
        if 'rawwords' in v:
            n = v['len']
            bs = b''.join(w.to_bytes(4, 'little') for w in v['rawwords'])
            el = t[1] if t[0] in ('vector', 'list') else U8
            esize = el[1] // 8 if el[0] == 'uint' else 1
            return {'elems': list(bs[:n]), 'esize': 1}, (n % esize != 0 or n > 4 * 2 ** v['depth'])
        if 'fields' in v:
            f, bad = {}, False
            for k, x in v['fields'].items():
                i = field_index(t, k)
                f[k], b = to_plain(t[1][i][1], x) if is_raw(x) else (x, False)
                bad = bad or b
            return {'fields': f}, bad
        return v, False
    plain, bad = to_plain(t, v)
    return plain, bad


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--cs', required=True)
    ap.add_argument('--out', required=True)
    a = ap.parse_args()
    types = ref_types(a.repo, a.cs)
    out = []
    for c in cases():
        if is_raw(c['value']):
            c['source'] = 'representation'
            plain, bad = raw_valid(c, types)
            if bad:
                c['verdict'] = 'refuse'
                c['reason'] = 'representation: stray bits past the length, storage that cannot hold the length, or a byte length that is not whole elements'
            else:
                d = dict(c, value=plain)
                decide(d, types)
                c['verdict'], c['hex'], c['root'] = d['verdict'], d.get('hex'), d.get('root')
                c['reason'] = d.get('reason', '')
        else:
            decide(c, types)
        annotate(types[c['type']], c['value'])
        out.append(c)
    by = {}
    for c in out:
        k = (c['class'], c['verdict'])
        by[k] = by.get(k, 0) + 1
    json.dump({'classes': CLASSES, 'cases': [dict(c, value=compress(c['value'])) for c in out]}, open(a.out, 'w'), indent=1)
    print('cases %d' % len(out))
    for k in sorted(by):
        print('  %-16s %-7s %d' % (k[0], k[1], by[k]))


if __name__ == '__main__':
    main()
