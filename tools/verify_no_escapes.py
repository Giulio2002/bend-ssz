#!/usr/bin/env python3
"""Refuse the checker's escape hatches in every .bend file of the tree (vendor/ included).

    python3 tools/verify_no_escapes.py              # self-test on the planted cases, then scan the tree
    python3 tools/verify_no_escapes.py FILE...      # self-test, then scan only these files
    python3 tools/verify_no_escapes.py --probe      # (ssz server) run the planted forms through the checker

The forms are read off the pinned checker's parser (toolchain.lock.json: bend2/bend.ts at
aa99b746; parse_book/parse_def have the same three forms as at 3ddfb036, the build pinned before), which is the only place a def becomes unsafe (`def.u`) or foreign (`def.i`):

  parse_book   `@` is parse_take("@") and then parse_word("unsafe"): parse_skip runs in between,
               so any whitespace, newlines and `#` comments may separate them (`@ # x\\n unsafe`).
  parse_def    parse_word("def"), parse_name, then parse_take("?"): `def f?(..)` is
               `@unsafe def f(..)`; the name may follow `def` after any whitespace or comments,
               the `?` must touch the name.
  parse_def    after the signature, parse_eat(":") and parse_at_word("import") (both skip
               whitespace and comments), then parse_eat('"'): a foreign body is `import` then a
               string, with or without space, on the same line or not (`: import "x.js"`,
               `:import"x.js"`, `:\\n  import\\n "x.c"`), repeated for several imports.
  book_load    file-level imports (`import Base`, `import path.bend as X`) are unquoted and must
               name a .bend file; they cannot bring in foreign code.

Base's own foreign defs (base.bend, `b === true`) are the checker's, pinned by hash. main.ts's
cli_verdict fails the check ("SOME PROOFS FAIL", "Error: N defs rely on unsafe or foreign code") when
any def outside Base relies on one, walking the whole book, imports included (2.0.28's report covered
only the top file's defs and the laws). This scan is a second guard over every file, run before any
check.

The scan works on a skeleton of each file that the lexer keeps aligned with the checker's
tokens: `#` comments (to end of line) become blanks, string literals keep their quotes but lose
their contents (escapes `\\"`, `\\\\`, `\\u{..}` understood), and char literals (`'#'`, `'"'`)
become blanks. On the skeleton, whole-file regexes (whitespace and newlines allowed wherever
the parser skips) find:

  @\\s*unsafe                      the decorator
  def\\s+NAME\\s*\\?                 def f?( (tolerating a space before `?` too, which the parser
                                   would reject: stricter is safe)
  import\\s*"                      a foreign body

A file the lexer cannot follow (an unterminated string) is refused as unscannable. The planted
cases below (PLANTED) run first on every invocation; tools/check_fast.sh runs this before
checking anything. Exits 1 naming each offending line.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NAME = r'[A-Za-z_][\w.]*'
BAN = [(re.compile(r'@\s*unsafe(?![\w.])'), '@unsafe'),
       (re.compile(r'(?<![\w.])def\s+' + NAME + r'\s*\?'), 'def f?( (unsafe)'),
       (re.compile(r'(?<![\w.])import\s*"'), 'foreign body (import "...")')]
CHAR = re.compile(r"'(\\u\{[0-9A-Fa-f]+\}|\\.|[^\\'\n])'")


def skeleton(src):
    """src with comments and char literals blanked and string contents blanked (quotes kept);
    newlines are kept so offsets map to the same lines. Raises ValueError on an unterminated string."""
    out = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == '#':
            j = src.find('\n', i)
            j = n if j < 0 else j
            out.append(' ' * (j - i))
            i = j
        elif c == '"':
            j = i + 1
            while j < n and src[j] != '"':
                j += 2 if src[j] == '\\' else 1
            if j >= n:
                raise ValueError('unterminated string at offset %d' % i)
            out.append('"' + ''.join('\n' if x == '\n' else ' ' for x in src[i + 1:j]) + '"')
            i = j + 1
        elif c == "'" and CHAR.match(src, i):
            m = CHAR.match(src, i)
            out.append(' ' * (m.end() - i))
            i = m.end()
        else:
            out.append(c)
            i += 1
    return ''.join(out)


def scan(src):
    """[(line, what)] for every escape hatch in src."""
    try:
        sk = skeleton(src)
    except ValueError as e:
        return [(1, 'unscannable: ' + str(e))]
    hits = []
    for rx, what in BAN:
        for m in rx.finditer(sk):
            hits.append((sk.count('\n', 0, m.start()) + 1, what))
    return sorted(hits)


# (source, expected number of hits). Positive cases: forms the pinned parser accepts as unsafe or
# foreign (`--probe` runs each through the pinned checker, which must report it as relying on
# unsafe or foreign code). Negative cases: text that must not trip the scan.
PLANTED = [
    ('@unsafe def f() -> U32: 0\n', 1),
    ('@ unsafe def f() -> U32: 0\n', 1),
    ('@\nunsafe\ndef f() -> U32: 0\n', 1),
    ('@ # a comment\n  unsafe def f() -> U32: 0\n', 1),
    ('@unsafe\n\ndef f() -> U32: 0\n', 1),
    ('def f?() -> U32: 0\n', 1),
    ('def\n  f?() -> U32: 0\n', 1),
    ('def # c\n f.g?(x: U32) -> U32: x\n', 1),
    ('def f?(x: U32) -> U32:\n  x\n', 1),
    ('def f() -> IO(Unit): import "x.js"\n', 1),
    ('def f() -> IO(Unit):import"x.js"\n', 1),
    ('def f() -> IO(Unit):\n  import\n  "x.c"\n', 1),
    ('def f() -> IO(Unit): # c\n  import # c\n  "x.js"\n', 1),
    ('def f() -> IO(Unit): import "a.js" import "b.js"\n', 2),
    ('def f(x: U32) -> U32:\n  x\ndef g() -> IO(Unit): import "y.js"\n', 1),
    ('def s() -> String: "#"\ndef f() -> IO(Unit): import "x.js"\n', 1),
    ("def c() -> Char: '\"'\ndef f() -> IO(Unit): import \"x.js\"\n", 1),
    ("def c() -> Char: '#'\n@unsafe def f() -> U32: 0\n", 1),
    ('def s() -> String: "a\\"b"\ndef f?() -> U32: 0\n', 1),
    ('def s() -> String: "open\n', 1),  # unterminated: refused as unscannable
    # negatives
    ('# @unsafe def f?() -> U32: import "x.js"\n', 0),
    ('def f() -> U32: 0  # @unsafe, def g?(, import "x.js"\n', 0),
    ('def s() -> String: "@unsafe def f?() import \\"x.js\\""\n', 0),
    ("def c() -> Char: '@'\ndef unsafe_ok() -> U32: 0\n", 0),
    ('def f(x: U32) -> U32: ?hole\n', 0),
    ('def important() -> U32: 0\ndef imports(x: U32) -> U32: x\n', 0),
    ('import Base\nimport ../src/model.bend as M\n', 0),
    ('def f(x: U32) -> U32: x.unsafe\n', 0),
]


def self_test():
    bad = []
    for src, want in PLANTED:
        got = scan(src)
        if len(got) != want:
            bad.append('%r: expected %d hit(s), got %r' % (src, want, got))
    if bad:
        print('verify_no_escapes: self-test failed:\n  ' + '\n  '.join(bad))
        sys.exit(2)


def files(args):
    if args:
        return [os.path.abspath(a) for a in args]
    out = []
    for d, ds, fs in os.walk(ROOT):
        ds[:] = [x for x in ds if not x.startswith('.') and x not in ('build', 'node_modules')]
        out += [os.path.join(d, f) for f in fs if f.endswith('.bend')]
    return sorted(out)


def probe():
    """Server only: write every positive planted case that the lexer can follow to a temporary
    .bend file and check it with the pinned checker (tools/check.sh); each must pass the parser
    and be reported as relying on unsafe or foreign code. Evidence that the planted forms are
    ones the checker accepts, not just ones the regexes catch."""
    import subprocess
    import tempfile
    bad = []
    with tempfile.TemporaryDirectory() as t:
        for k, (src, want) in enumerate(PLANTED):
            if want == 0 or scan(src)[0][1].startswith('unscannable'):
                continue
            f = os.path.join(t, 'p%02d.bend' % k)
            with open(f, 'w') as h:
                h.write('import Base\n' + src)
            r = subprocess.run([os.path.join(ROOT, 'tools/check.sh'), f], capture_output=True, text=True,
                               cwd=ROOT)
            out = r.stdout + r.stderr
            # 2.0.28: "All terms check, but N defs rely on ..."; 2.0.34: "SOME PROOFS FAIL" with
            # "Error: N def(s) rel(y|ies) on unsafe or foreign code"
            ok = re.search(r'(All terms check, but|Error:) \d+ defs? rel(y|ies) on unsafe or foreign code', out)
            print('%s %r' % ('accepted-as-unsafe' if ok else 'NOT-REPORTED', src))
            if not ok:
                bad.append('%r:\n%s' % (src, out[-600:]))
    if bad:
        print('verify_no_escapes --probe: the checker did not report these as unsafe/foreign:\n' + '\n'.join(bad))
        sys.exit(1)


def main():
    self_test()
    if sys.argv[1:] == ['--probe']:
        probe()
        return
    bad = []
    fs = files(sys.argv[1:])
    for p in fs:
        with open(p, errors='replace') as h:
            src = h.read()
        bad += ['%s:%d: %s' % (os.path.relpath(p, ROOT), n, what) for n, what in scan(src)]
    if bad:
        print('verify_no_escapes: escape hatches found:\n  ' + '\n  '.join(bad[:50]))
        sys.exit(1)
    print('verify_no_escapes: %d planted cases ok; %d .bend files, no escape hatch' % (len(PLANTED), len(fs)))


if __name__ == '__main__':
    main()
