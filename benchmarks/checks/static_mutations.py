"""Malformed variants of every ssz_static case through the compact API
(build/compact-dec: API.validate, exit 1 on rejection). The
expected verdict of each mutated input comes from the independent Python
validator in benchmarks/checks/ref_validate.py, not from an assumption that a mutation must
be invalid: appending a byte to a variable-size value can be legal."""
import json, subprocess, os, re, snappy, pathlib, collections, sys, importlib.util
spec = importlib.util.spec_from_file_location('ref', 'benchmarks/checks/ref_validate.py')
src = pathlib.Path('benchmarks/checks/ref_validate.py').read_text().split('tree = G.parse')[0]
ref = {}; exec(compile(src, 'ref_validate', 'exec'), ref)
names = json.load(open('build/cschema-index.json'))
cases = [c for c in json.load(open('cases.json')) if '/ssz_static/' in c]
tmp = pathlib.Path('build/performance/inputs'); tmp.mkdir(parents=True, exist_ok=True)
tally = collections.Counter(); bad = []
for c in cases:
    t = c.split('/')[4]
    data = snappy.decompress((pathlib.Path('fixtures') / c / 'serialized.ssz_snappy').read_bytes())
    tree = ref['G'].parse(ref['defs'][t], ref['defs'])
    muts = [('truncated', data[:-1]), ('extended', data + b'\x00')]
    if len(data) >= 4: muts.append(('offset_ffffffff', b'\xff\xff\xff\xff' + data[4:]))
    if len(data) >= 1: muts.append(('flip_first', bytes([data[0] ^ 0x80]) + data[1:]))
    # Header words: add 1 to each of the first 16 little-endian words, which
    # covers the offsets of most containers' variable fields (first offset,
    # later offsets, end-of-region comparisons).
    for k in range(min(16, len(data) // 4)):
        w = (int.from_bytes(data[4 * k:4 * k + 4], 'little') + 1) & 0xffffffff
        muts.append(('word%d_plus1' % k, data[:4 * k] + w.to_bytes(4, 'little') + data[4 * k + 4:]))
    for label, m in muts:
        expect_valid = ref['check'](tree, m, [], [])
        f = tmp / 'mut.ssz'; f.write_bytes(m)
        env = {**os.environ, 'SSZ_INDEX': str(names.index(t)), 'SSZ_OPS': '1', 'SSZ_INPUT': str(f)}
        r = subprocess.run(['build/compact-dec', '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True)
        accepted = r.returncode == 0
        tally[(label, 'valid' if expect_valid else 'invalid', 'agree' if accepted == expect_valid else 'DISAGREE')] += 1
        if accepted != expect_valid: bad.append((c, label, expect_valid, r.returncode))
for k, v in sorted(tally.items()): print(v, k)
print('disagreements', len(bad)); [print(b) for b in bad[:10]]
json.dump({'tally': {' '.join(k): v for k, v in tally.items()}, 'disagreements': bad}, open('benchmarks/evidence/static_mutations.json', 'w'), indent=1)
sys.exit(1 if bad else 0)
