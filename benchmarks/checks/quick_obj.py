"""Quick per-operation timings of the typed object programs, for development.

    /opt/homebrew/bin/python3 benchmarks/checks/quick_obj.py Name[,Name...]

One fixture per name, min of three runs of each of decode, encode and root
through build/obj-g<k> - the same programs and modes benchmarks/run.py measures,
without the alternating Go samples, the repetition or the report. It is a
development aid for spotting a regression between edits, never the contract
measurement.
"""
import json
import os
import pathlib
import re
import subprocess
import sys

import snappy

ROOT = pathlib.Path(__file__).resolve().parents[2]
os.chdir(ROOT)
GROUPS = json.load(open('types/obj_groups.json'))
CASES = [c for c in json.load(open('cases.json')) if '/ssz_static/' in c]
PICK = {}
for c in CASES:
    PICK.setdefault(c.split('/')[4], c)
TMP = pathlib.Path('build/performance/inputs')
TMP.mkdir(parents=True, exist_ok=True)

MODES = {'decode': '1', 'encode': '2', 'root': '3'}


def main():
    names = sys.argv[1].split(',')
    for t in names:
        if t not in PICK:
            print(f'{t:26} no static fixture')
            continue
        data = snappy.decompress((ROOT / 'fixtures' / PICK[t] / 'serialized.ssz_snappy').read_bytes())
        f = TMP / f'{t}.quick.ssz'
        f.write_bytes(data)
        out = TMP / 'quick-out.ssz'
        g = GROUPS[t]
        row = []
        for label, mode in MODES.items():
            ops = 200 if len(data) > 100000 else (20000 if len(data) > 2000 else 200000)
            best = None
            for _ in range(3):
                env = {**os.environ, 'SSZ_MODE': mode, 'SSZ_INDEX': str(g['index']),
                       'SSZ_OPS': str(ops), 'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(out)}
                r = subprocess.run([f"build/obj-g{g['group']}", '--threads', '1', '--gpu', 'off'],
                                   env=env, capture_output=True, text=True)
                m = re.search(r'\bMS=(\d+)', r.stdout)
                if not m:
                    print(f'{t} {label}: {r.stdout[-200:]}{r.stderr[-200:]}')
                    break
                ns = int(m.group(1)) * 1e6 / ops
                best = ns if best is None else min(best, ns)
            row.append(f'{label} {best:>10.1f} ns' if best is not None else f'{label} failed')
        print(f'{t:26} {len(data):>8} bytes  ' + '  '.join(row))


if __name__ == '__main__':
    main()
