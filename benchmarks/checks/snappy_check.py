"""benchmarks/snappy_block.py against python-snappy on every official fixture."""
import json, pathlib, sys
import snappy
sys.path.insert(0, 'benchmarks')
import snappy_block
bad = 0
cases = json.load(open('cases.json'))
for case in cases:
    raw = (pathlib.Path('fixtures') / case / 'serialized.ssz_snappy').read_bytes()
    bad += snappy_block.decompress(raw) != snappy.decompress(raw)
print('fixtures', len(cases), 'mismatches', bad)
sys.exit(1 if bad else 0)
