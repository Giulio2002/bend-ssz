#!/usr/bin/env python3
"""Check the trusted toolchain against toolchain.lock.json.

    python3 tools/verify_pins.py                      # the vendored SHA-256 package only
    python3 tools/verify_pins.py --toolchain T        # and the checker under T (bun, bend2/*)
    python3 tools/verify_pins.py --toolchain T --lib L  # and the package cache L, if not the vendored one

Exits 1, naming each file whose sha256 differs from the lock, or that is missing. tools/check.sh
and tools/check_fast.sh run it before checking anything, so a verdict is only printed for the
pinned checker on the pinned package. Reads a few MB; safe to run anywhere.

Tree hashes (the package): sha256 over the sorted lines "<relative path>\\0<sha256 of file>\\n".
When the lock records manifest_sha256, the package directory must also be the whole published
package: its BendHub id, recomputed from its files (hub_id), must be the pinned id.
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


def hub_id(d):
    """The BendHub id of a package directory: '0x' + the first 32 hex digits of the sha256 of its
    manifest, the sorted lines '<sha256 of file> <relative path>' (each ending in a newline)."""
    files = sorted(os.path.relpath(os.path.join(a, f), d) for a, _, fs in os.walk(d) for f in fs)
    man = ''.join('%s %s\n' % (file_hash(os.path.join(d, f)), f) for f in files)
    return '0x' + hashlib.sha256(man.encode()).hexdigest()[:32]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--toolchain', help='checker directory (tools/check.sh BEND_TOOLCHAIN): the files listed under checker.files, and bun if the lock pins one')
    ap.add_argument('--lock', default=os.path.join(ROOT, 'toolchain.lock.json'), help='the lock to verify against (tools/check.sh BEND_LOCK)')
    ap.add_argument('--lib', help='BendHub package cache in use (tools/check.sh BEND_LIB); default the vendored copy')
    a = ap.parse_args()
    lock = json.load(open(a.lock))
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
        elif pkg.get('manifest_sha256') and hub_id(d) != pkg['id']:
            bad.append('%s: BendHub id %s, pinned %s' % (d, hub_id(d), pkg['id']))

    if a.toolchain:
        chk = lock['checker']
        bun = [(lock['bun']['path'], lock['bun']['sha256'])] if 'bun' in lock else []
        for rel, want in list(chk['files'].items()) + bun:
            p = os.path.join(a.toolchain, rel)
            if not os.path.isfile(p):
                bad.append('%s: missing' % p)
            elif file_hash(p) != want:
                bad.append('%s: sha256 %s, pinned %s' % (p, file_hash(p), want))

    if bad:
        print('verify_pins: MISMATCH against %s:' % a.lock + '\n  ' + '\n  '.join(bad))
        sys.exit(1)


if __name__ == '__main__':
    main()
