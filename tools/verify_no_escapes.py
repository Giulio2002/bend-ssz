#!/usr/bin/env python3
"""Refuse the checker's escape hatches, textually, in every .bend file of the tree (vendor/ included).

    python3 tools/verify_no_escapes.py

The pinned checker accepts `@unsafe def`, `def f?(..)` (the same as @unsafe) and foreign bodies
(`import "..."` in a def body), and then prints "All terms check, but N defs rely on unsafe or
foreign code". tools/check_fast.sh accepts only the exact line "All terms check."; this scan makes
the ban independent of the checker's wording. Holes (?name) fail every check anyway. Comments are
ignored. Exits 1 naming each offending line.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BAN = [(re.compile(r'@unsafe\b'), '@unsafe'),
       (re.compile(r'^\s*def\s+[A-Za-z_][\w.]*\?\s*\('), 'def f?( (unsafe)'),
       (re.compile(r'^\s*import\s+"'), 'foreign body (import "...")')]


def main():
    bad = []
    for d, ds, fs in os.walk(ROOT):
        ds[:] = [x for x in ds if not x.startswith('.') and x not in ('build', 'node_modules')]
        for f in fs:
            if not f.endswith('.bend'):
                continue
            p = os.path.join(d, f)
            with open(p, errors='replace') as h:
                for n, line in enumerate(h, 1):
                    code = line.split('#', 1)[0]
                    for rx, what in BAN:
                        if rx.search(code):
                            bad.append('%s:%d: %s' % (os.path.relpath(p, ROOT), n, what))
    if bad:
        print('verify_no_escapes: escape hatches found:\n  ' + '\n  '.join(bad[:50]))
        sys.exit(1)


if __name__ == '__main__':
    main()
