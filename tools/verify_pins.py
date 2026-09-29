#!/usr/bin/env python3
"""Check the trusted toolchain against toolchain.lock.json.

    python3 tools/verify_pins.py                      # the vendored SHA-256 package only
    python3 tools/verify_pins.py --toolchain T        # and the checker under T (bun, bend2/*)
    python3 tools/verify_pins.py --toolchain T --lib L  # and the package cache L, if not the vendored one

Exits 1, naming each file whose sha256 differs from the lock, or that is missing. tools/check.sh
and tools/check_fast.sh run it before checking anything, so a verdict is only printed for the
pinned checker on the pinned package. Reads a few MB; safe to run anywhere.

Tree hashes (the package): sha256 over the sorted lines "<relative path>\\0<sha256 of file>\\n".
"""
import argparse
import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def file_hash(p):
    with open(p, 'rb') as h:
        return hashlib.sha256(h.read()).hexdigest()


def tree_hash(d):
    files = sorted(os.path.relpath(os.path.join(a, f), d) for a, _, fs in os.walk(d) for f in fs)
    h = hashlib.sha256()
    for f in files:
        h.update(f.encode() + b'\0' + file_hash(os.path.join(d, f)).encode() + b'\n')
    return h.hexdigest(), len(files)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--toolchain', help='directory with bun-linux-x64/bun and bend-src/ (tools/check.sh BEND_TOOLCHAIN)')
    ap.add_argument('--lib', help='BendHub package cache in use (tools/check.sh BEND_LIB); default the vendored copy')
    a = ap.parse_args()
    lock = json.load(open(os.path.join(ROOT, 'toolchain.lock.json')))
    bad = []

    pkg = lock['sha256_package']
    libs = [os.path.join(ROOT, pkg['vendored'])]
    if a.lib:
        libs.append(os.path.join(a.lib, pkg['id']))
    for d in libs:
        if not os.path.isdir(d):
            bad.append('%s: missing' % d)
            continue
        got, n = tree_hash(d)
        if got != pkg['tree_sha256']:
            bad.append('%s: tree sha256 %s (%d files), pinned %s' % (d, got, n, pkg['tree_sha256']))

    if a.toolchain:
        chk = lock['checker']
        for rel, want in list(chk['files'].items()) + [(lock['bun']['path'], lock['bun']['sha256'])]:
            p = os.path.join(a.toolchain, rel)
            if not os.path.isfile(p):
                bad.append('%s: missing' % p)
            elif file_hash(p) != want:
                bad.append('%s: sha256 %s, pinned %s' % (p, file_hash(p), want))

    if bad:
        print('verify_pins: MISMATCH against toolchain.lock.json:\n  ' + '\n  '.join(bad))
        sys.exit(1)


if __name__ == '__main__':
    main()
