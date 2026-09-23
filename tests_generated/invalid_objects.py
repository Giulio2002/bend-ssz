"""Invalid representable objects are refused by the public checked encoder.

    /opt/homebrew/bin/python3 tests_generated/invalid_objects.py

build/compact-oinvalid (benchmarks/compact/oinvalid.bend) builds each value
with the raw record constructors - uint8 above 255, bits set past a byte
vector's length, slack bytes set in a byte list's last word, storage smaller
than the length, a bit list and a packed list one past their limits, a packed
list whose length is not a whole number of elements, a boxed field with no
value - and prints whether `<Name>_serialize` accepted it. Each invalid case
has a valid control. Finite regressions, not laws.
"""
import json
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
EXPECT = {'uint8_300': 0, 'uint8_200': 1, 'bytes1_tail': 0, 'bytes1_ok': 1,
          'tx_slack': 0, 'tx_ok': 1, 'tx_capacity': 0,
          'att_bits_over': 0, 'att_bits_limit': 1,
          'columns_over': 0, 'columns_limit': 1, 'columns_unit': 0,
          'box_empty': 0, 'box_ok': 1}


def main():
    exe = ROOT / 'build/compact-oinvalid'
    r = subprocess.run([str(exe), '--threads', '1', '--gpu', 'off'], capture_output=True, text=True, cwd=ROOT)
    got = {}
    for line in r.stdout.splitlines():
        if '=' in line:
            k, v = line.split('=', 1)
            got[k.strip()] = int(v.strip())
    rows, bad = [], 0
    for k, want in EXPECT.items():
        ok = got.get(k) == want
        bad += not ok
        rows.append({'case': k, 'accepted': got.get(k), 'expected': want, 'pass': ok})
        print(('pass ' if ok else 'FAIL ') + f'{k}: accepted={got.get(k)} expected={want}')
    out = ROOT / 'benchmarks/evidence/invalid_objects.json'
    out.write_text(json.dumps({'exit': r.returncode, 'cases': rows, 'failed': bad}, indent=1) + '\n')
    print(f'{len(rows) - bad}/{len(rows)} invalid-object cases behave as required')
    return 0 if bad == 0 and r.returncode == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
