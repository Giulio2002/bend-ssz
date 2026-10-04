# Shapes for amp.py (exec'd there: minval, with_field, field_t, T are in scope). SHAPES(target) -> [(name, label, build(n) -> value, n)].
# Each build fills one list node (path) with n copies of an element value; n is 2^k + 1 (the array of a list then has twice the
# slots it needs) unless the label says otherwise, the largest such count of about `target` input bytes, capped at the list's limit.

PROG = 2 ** 32


def _enc_len(name, b, n):
    t = T[name][0]
    return len(enc(t, b(n)))  # noqa: F821  (amp.enc)


def _pick(name, b, lim, target, mode='p1'):
    s0 = _enc_len(name, b, 0)
    per = max(1e-9, (_enc_len(name, b, 64) - s0) / 64)
    n = int((target - s0) / per)
    n = max(1, min(lim, n))
    p = 1 << (n.bit_length() - 1)
    if mode == 'p1':
        c = p + 1 if p + 1 <= n else p // 2 + 1
    elif mode == 'p':
        c = p
    else:
        c = n
    return max(1, min(lim, c))


def _fill(name, path, elem_fn):
    t = T[name][0]
    base = minval(t)
    return lambda n: with_field(t, base, path, [elem_fn(i) for i in range(n)])


def _lim(name, path):
    lt = field_t(T[name][0], path)
    return lt.size if lt.kind in ('list', 'bytelist', 'bitlist') else PROG


def SHAPES(target):
    out = []

    def add(name, label, path, elem_fn, mode='p1', lim=None):
        b = _fill(name, path, elem_fn)
        lim = lim or _lim(name, path)
        out.append((name, label, b, _pick(name, b, lim, target, mode)))

    tx = {'ExecutionPayload': ('transactions',), 'BeaconBlockBody': ('execution_payload', 'transactions'),
          'BeaconBlock': ('body', 'execution_payload', 'transactions'), 'SignedBeaconBlock': ('message', 'body', 'execution_payload', 'transactions')}
    for L in range(0, 65):
        add('ExecutionPayload', 'transactions.[%dB]' % L, tx['ExecutionPayload'], lambda i, L=L: bytes(L))
    add('ExecutionPayload', 'transactions.[1B ff]', tx['ExecutionPayload'], lambda i: b'\xff')
    add('ExecutionPayload', 'transactions.[1B] count 2^k', tx['ExecutionPayload'], lambda i: b'\x00', mode='p')
    add('ExecutionPayload', 'transactions.[0B|1B alternating]', tx['ExecutionPayload'], lambda i: bytes(i & 1))
    add('ExecutionPayload', 'transactions.[1B] count 2^k+1 at 2^20 limit', tx['ExecutionPayload'], lambda i: b'\x00', mode='n')
    for nm in ('BeaconBlockBody', 'BeaconBlock', 'SignedBeaconBlock'):
        for L in (0, 1, 2):
            add(nm, '%s.[%dB]' % ('.'.join(tx[nm]), L), tx[nm], lambda i, L=L: bytes(L))
    # every list of BeaconState, zero and non-zero elements
    bs = T['BeaconState'][0]
    for f, ft in bs.fields:
        if ft.kind in ('list',):
            e = ft.elem
            add('BeaconState', '%s.[]' % f, (f,), lambda i, e=e: minval(e))
    # DataColumnSidecar, ExecutionRequests
    for f in ('column', 'kzg_commitments', 'kzg_proofs'):
        e = dict(T['DataColumnSidecar'][0].fields)[f].elem
        add('DataColumnSidecar', '%s.[]' % f, (f,), lambda i, e=e: minval(e))
    add('DataColumnSidecar', 'column.[] at the 4096 limit', ('column',), lambda i: minval(dict(T['DataColumnSidecar'][0].fields)['column'].elem), mode='n')
    for f, ft in T['ExecutionRequests'][0].fields:
        add('ExecutionRequests', '%s.[]' % f, (f,), lambda i, e=ft.elem: minval(e))
    # progressive containers
    pc = T['ProgressiveComplexTestStruct'][0]
    vt = dict(pc.fields)['f_F'].elem.elem          # VarTestStruct
    pvt = dict(pc.fields)['f_H'].elem              # ProgressiveVarTestStruct

    def var(j):
        return {**minval(vt), 'f_B': [0] * j}

    for m in range(0, 5):
        for j in (0, 1, 2):
            if m == 0 and j:
                continue
            add('ProgressiveComplexTestStruct', 'f_F.[%d x VarTestStruct(f_B=%d)]' % (m, j), ('f_F',), lambda i, m=m, j=j: [var(j)] * m)
            if m <= 2:
                add('ProgressiveTestStruct', 'f_D.[%d x VarTestStruct(f_B=%d)]' % (m, j), ('f_D',), lambda i, m=m, j=j: [var(j)] * m)
    for j in (0, 1, 2, 3):
        add('ProgressiveComplexTestStruct', 'f_F.[0].[VarTestStruct(f_B=%d)]' % j, ('f_F', '0'), lambda i, j=j: var(j))
    for j in (0, 1, 2):
        for bits in (0, 1, 7, 8, 9, 31, 32, 33):
            add('ProgressiveComplexTestStruct', 'f_H.[PVT(f_B=%d,f_C=%db)]' % (j, bits), ('f_H',),
                lambda i, j=j, bits=bits: {**minval(pvt), 'f_B': [0] * j, 'f_C': [False] * bits})
    se = dict(pc.fields)['f_E'].elem
    add('ProgressiveComplexTestStruct', 'f_E.[]', ('f_E',), lambda i: minval(se))
    add('ProgressiveComplexTestStruct', 'f_D.[] 2^k bytes', ('f_D',), lambda i: 0, mode='p')
    add('ProgressiveTestStruct', 'f_A.[] bools', ('f_A',), lambda i: False)
    add('ProgressiveTestStruct', 'f_C.[]', ('f_C',), lambda i: minval(se))
    # progressive bit lists: 2^k + 1 bits (via a list of bools; one field)
    for f in ('f_C', 'f_L'):
        add('ProgressiveBitsStruct', '%s.bits 2^k+1' % f, (f,), lambda i: False)
    add('CompatibleUnionABCA', '<2>.f_C.bits 2^k+1', ('2', 'f_C'), lambda i: False)
    add('ProgressiveComplexTestStruct', 'f_C.bits 2^k+1', ('f_C',), lambda i: False)
    return out


_SHAPES1 = SHAPES


def SHAPES(target):  # noqa: F811
    out = _SHAPES1(target)
    t = T['DataColumnSidecar'][0]
    fs = dict(t.fields)

    def all3(n):
        v = minval(t)
        for f in ('column', 'kzg_commitments', 'kzg_proofs'):
            v[f] = [minval(fs[f].elem)] * n
        return v
    out.append(('DataColumnSidecar', 'column, kzg_commitments, kzg_proofs all at the 4096 limit', all3, 4096))
    return out
