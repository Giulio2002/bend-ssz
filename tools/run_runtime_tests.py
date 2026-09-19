#!/usr/bin/env python3
"""Run Bun tests against the actual compiled Bend modules of the pinned 2.0.16 toolchain.

Every `.bend` import goes through tools/bend_loader.ts, which returns the ES module
that the pinned compiler emits. Fails on any test failure, load/compile error,
missing file, or an empty run.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
BUN = '/Users/monkeair/.bun/bin/bun'
LOADER = ROOT / 'tools/bend_loader.ts'
BASELINE = {'iteration': '0011 (Bend 2.0.5, historical)', 'tests': 51, 'assertions': 20009}


def main(argv):
    if not argv:
        print('run_runtime_tests: no test files given', file=sys.stderr)
        return 2
    lock = json.loads((ROOT / 'automation/toolchain.json').read_text())
    for key in ('bend', 'base'):
        if hashlib.sha256(Path(lock[key]['path']).read_bytes()).hexdigest() != lock[key]['sha256']:
            print('run_runtime_tests: pinned toolchain changed: ' + key, file=sys.stderr)
            return 2
    files = []
    for name in argv:
        path = (ROOT / name).resolve()
        if not path.is_file() or not path.name.endswith('.test.ts'):
            print('run_runtime_tests: not a test file: ' + name, file=sys.stderr)
            return 2
        files.append('./' + str(path.relative_to(ROOT)))
    command = [BUN, 'test', '--timeout', '600000', '--preload', str(LOADER), *files]
    print('RUN:', ' '.join(command), flush=True)
    env = {**os.environ, 'BEND_NO_TELEMETRY': '1', 'NO_COLOR': '1', 'FORCE_COLOR': '0'}
    result = subprocess.run(command, cwd=ROOT, env=env, text=True, capture_output=True)
    output = re.sub(r'\x1b\[[0-9;]*m', '', result.stdout + result.stderr)
    print(output, end='', flush=True)
    counts = {}
    for key, pattern in [('passed', r'^\s*(\d+) pass$'), ('failed', r'^\s*(\d+) fail$'),
                         ('errors', r'^\s*(\d+) errors?$'), ('assertions', r'^\s*(\d+) expect\(\) calls$')]:
        found = re.findall(pattern, output, re.M)
        counts[key] = int(found[-1]) if found else 0
    ran = re.findall(r'^Ran (\d+) tests? across (\d+) files?', output, re.M)
    counts['tests'] = int(ran[-1][0]) if ran else 0
    counts['files'] = int(ran[-1][1]) if ran else 0
    print(f"runtime tests: {counts['passed']}/{counts['tests']} passed, {counts['failed']} failed, "
          f"{counts['errors']} errors, {counts['assertions']} assertions, {counts['files']}/{len(files)} files "
          f"(baseline {BASELINE['iteration']}: {BASELINE['tests']} tests / {BASELINE['assertions']} assertions)")
    problems = []
    if result.returncode:
        problems.append(f'bun exited {result.returncode}')
    if counts['tests'] == 0 or counts['passed'] == 0:
        problems.append('zero tests ran')
    if counts['failed'] or counts['errors'] or counts['passed'] != counts['tests']:
        problems.append('failing or erroring tests')
    if counts['files'] != len(files):
        problems.append('not every test file ran')
    if re.search(r'bend loader: |error: ', output):
        problems.append('compile or load error reported')
    if problems:
        print('run_runtime_tests: FAILED: ' + '; '.join(problems), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
