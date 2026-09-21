"""Compare the compact access API (build/access_probe) with an independent
Python reading of the same BeaconState bytes."""
import re, subprocess, sys, pathlib, shutil
sys.path.insert(0, 'tools')
import generate_cschema as G
src = G.SOURCE.read_text()
defs = dict(re.findall(r'^def (\w+)\(\) -> T\.Schema: (.+)$', src, re.M))
state = G.parse(defs['BeaconState'], defs)
u32 = lambda b, o: int.from_bytes(b[o:o+4], 'little')
u64 = lambda b, o: '%d:%d' % (u32(b, o), u32(b, o + 4))

def fields(node, b, off, length):
    """(offset, length) of each field of a container window."""
    fl = G.fields_of(node[1]); pos = off; out = []; var = []
    for f in fl:
        s = G.fixed_size(f)
        if s is None: var.append((len(out), off + u32(b, pos))); out.append(None); pos += 4
        else: out.append((pos, s)); pos += s
    ends = [o for _, o in var[1:]] + [off + length]
    for (i, o), e in zip(var, ends): out[i] = (o, e - o)
    return fl, out

def expected(b):
    fl, fv = fields(state, b, 0, len(b))
    e = {'slot': u64(b, fv[2][0])}
    vo, vl = fv[11]; n = vl // 121; e['validators'] = str(n)
    if n: e['last_validator_effective_balance'] = u64(b, vo + (n - 1) * 121 + 48 + 32)
    e['balances'] = str(fv[12][1] // 8); e['historical_roots'] = str(fv[7][1] // 32)
    e['proposer_lookahead_3'] = u64(b, fv[37][0] + 24)
    ho, hl = fv[24]; e['payload_header'] = '%d+%d' % (ho, hl)
    hfl, hfv = fields(fl[24], b, ho, hl); e['extra_data'] = '%d+%d' % hfv[10]
    e['payload_header_encoding'] = '%d/%d' % (sum(b[ho:ho + hl]) % 2**32, hl)
    e['eth1_votes'] = str(fv[9][1] // 72)
    return e

bad = 0
for c in range(5):
    data = pathlib.Path(f'build/native/case_{c}.ssz').read_bytes()
    shutil.copy(f'build/native/case_{c}.ssz', 'build/native/input.ssz')
    out = subprocess.run(['build/access_probe'], capture_output=True, text=True).stdout
    got = dict(l.split('=', 1) for l in out.split() if '=' in l)
    for k, v in expected(data).items():
        ok = got.get(k) == v
        bad += not ok
        print(c, k, v, 'OK' if ok else 'MISMATCH got ' + str(got.get(k)))
print('mismatches', bad)
sys.exit(1 if bad else 0)
