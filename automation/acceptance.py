"""Frozen execution gates. Semantic proof completeness requires independent audit."""
import hashlib
import json
import os
import re
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
BEND = '/Users/monkeair/.bend/bin/bend'
BUN = '/Users/monkeair/.bun/bin/bun'
ENV = {**os.environ, 'BEND_NO_TELEMETRY': '1'}


def run(command):
    print('CHECK:', command, flush=True)
    result = subprocess.run(command, cwd=ROOT, env=ENV, text=True, capture_output=True)
    print(result.stdout, end='', flush=True)
    print(result.stderr, end='', file=sys.stderr, flush=True)
    if result.returncode:
        raise SystemExit(result.returncode)
    if command[0] == BEND:
        output = result.stdout + result.stderr
        if 'All terms check' not in output or re.search(r'\b[1-9][0-9]* unsafe annotations?\b|@unsafe', output):
            raise SystemExit('Pinned checker must check all terms with ZERO unsafe annotations')



def check_inventory():
    manifest = json.loads((ROOT / 'fixtures.manifest.json').read_text())
    actual = {str(p.relative_to(ROOT / 'fixtures')) for p in (ROOT / 'fixtures').rglob('*') if p.is_file()}
    if actual != set(manifest):
        raise SystemExit('Fixture inventory changed')
    for name, expected in manifest.items():
        if hashlib.sha256((ROOT / 'fixtures' / name).read_bytes()).hexdigest() != expected:
            raise SystemExit('Fixture checksum mismatch: ' + name)
    cases = json.loads((ROOT / 'cases.json').read_text())
    if cases != sorted({str(Path(n).parent) for n in manifest}):
        raise SystemExit('Case manifest mismatch')
    return cases


def main():
    lock = json.loads((ROOT / 'automation/toolchain.json').read_text())
    for key in ('bend', 'base'):
        item = lock[key]
        if hashlib.sha256(Path(item['path']).read_bytes()).hexdigest() != item['sha256']:
            raise SystemExit('Pinned 2.0.16 toolchain identity changed: ' + key)
    expected = check_inventory()
    run([BEND, 'PROOF.bend'])
    runtime = ROOT / 'tools/run_runtime_tests.py'
    if not runtime.is_file():
        raise SystemExit('INCOMPLETE: implement current-toolchain runtime test adapter')
    tests = ['tests/sha256.test.ts'] + [str(p.relative_to(ROOT)) for p in sorted((ROOT / 'tests/new').glob('*.test.ts'))]
    run([sys.executable, str(runtime), *tests])
    if not (ROOT / 'tools/spectests.py').is_file():
        raise SystemExit('INCOMPLETE: SSZ spectest runner is missing')
    report = ROOT / 'build/spectests.json'
    report.parent.mkdir(exist_ok=True)
    report.unlink(missing_ok=True)
    run([sys.executable, 'tools/spectests.py', '--report', str(report)])
    result = json.loads(report.read_text())
    rows = result['cases']
    if sorted(row['case'] for row in rows) != expected or any(row['status'] != 'passed' for row in rows):
        raise SystemExit('Every unique official SSZ case must pass; no skips or missing cases')
    check_inventory()
    if not (ROOT / 'END_TO_END.bend').is_file():
        raise SystemExit('INCOMPLETE: end-to-end SSZ proof missing')
    run([BEND, 'END_TO_END.bend'])
    # A checker exit and theorem names cannot establish semantic completeness.
    # Frozen objective, auditor and orchestrator must inspect all propositions,
    # their public-implementation connection, dependencies, and full type coverage.


if __name__ == '__main__':
    main()
