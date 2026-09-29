#!/usr/bin/env python3
"""Check that the frozen statements are the ones recorded in frozen.lock.json.

    python3 tools/verify_frozen.py            # check (exit 1 naming every difference)
    python3 tools/verify_frozen.py --update   # rewrite the lock (a deliberate, reviewed change only)

What is frozen, and how it is hashed:
  - whole files (sha256): spec/*.bend (the specification), the representations it imports
    (types/{schema,primitive,byte_alias,list_alias}.bend), schemas/*.json, the normative sources
    vendor/consensus-specs/{ssz/simple-serialize.md,fulu_mainnet.py}, and
    memory_bench/law-statements.json;
  - the statements of END_TO_END.bend, ROOT_DOMAIN.bend, PROOF.bend and HASH_PROOF.bend (sha256
    of their statement text): every import whose alias the statements use (PROOF.bend, which
    only imports, keeps all of them), every `law` block, the signature line of every def
    whose result is an equality proposition, and every other def whole; comments, blank lines and
    the bodies of the defs that prove a law (def NAME for law NAME, or `-> {...}:` defs) are
    left out, so the proofs can change and the statements cannot;
  - memory_bench/law-statements.json must hold exactly END_TO_END.bend's law blocks, verbatim.

tools/check_fast.sh runs this check before checking anything. The lock's own sha256 is printed
by --update and recorded in README ("Confirming what was checked").
"""
import glob
import hashlib
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOCK = os.path.join(ROOT, 'frozen.lock.json')
ROOTS = ['END_TO_END.bend', 'ROOT_DOMAIN.bend', 'PROOF.bend', 'HASH_PROOF.bend']


def whole_files():
    fs = sorted(glob.glob('spec/*.bend', root_dir=ROOT))
    fs += ['types/schema.bend', 'types/primitive.bend', 'types/byte_alias.bend', 'types/list_alias.bend']
    fs += sorted(glob.glob('schemas/*.json', root_dir=ROOT))
    fs += ['vendor/consensus-specs/ssz/simple-serialize.md', 'vendor/consensus-specs/fulu_mainnet.py',
           'memory_bench/law-statements.json']
    return fs


def blocks(text):
    """Top-level blocks: a non-indented line and the indented lines after it (comments dropped)."""
    out = []
    for line in text.split('\n'):
        s = line.rstrip()
        if not s.strip() or s.lstrip().startswith('#'):
            continue
        if s[0] in ' \t' and out:
            out[-1].append(s)
        else:
            out.append([s])
    return out


def statements(text):
    bs = blocks(text)
    laws = {re.match(r'law (\S+):', b[0]).group(1) for b in bs if b[0].startswith('law ')}
    keep = []
    for b in bs:
        m = re.match(r'def ([^(\s:]+)', b[0])
        if m and m.group(1) in laws:
            continue  # the proof of a law: its statement is the law block
        if m and re.search(r'-> \{.*\}:\s*$', b[0]):
            keep.append(b[0])  # an equality proposition: the signature is the statement
            continue
        keep.extend(b)
    # an import counts when the statements use its alias (proof-only imports may change)
    body = '\n'.join(l for l in keep if not l.startswith('import '))
    out = []
    for l in keep:
        m = re.match(r'import \S+ as (\w+)', l)
        if m and body and not re.search(r'\b%s\.' % re.escape(m.group(1)), body):
            continue
        out.append(l)
    return '\n'.join(out) + '\n'


def law_blocks(text):
    """END_TO_END's law blocks as memory_bench/law-statements.json stores them."""
    out, cur = {}, None
    for line in text.split('\n'):
        m = re.match(r'law (\S+):', line)
        if m:
            cur = m.group(1)
            out[cur] = line + '\n'
        elif cur and line.startswith(' '):
            out[cur] += line + '\n'
        else:
            cur = None
    return out


def sha(b):
    return hashlib.sha256(b).hexdigest()


def compute():
    files = {f: sha(open(os.path.join(ROOT, f), 'rb').read()) for f in whole_files()}
    stm = {f: sha(statements(open(os.path.join(ROOT, f)).read()).encode()) for f in ROOTS}
    return {'files': files, 'statements': stm}


def main():
    cur = compute()
    bad = []
    e2e = law_blocks(open(os.path.join(ROOT, 'END_TO_END.bend')).read())
    frozen = json.load(open(os.path.join(ROOT, 'memory_bench/law-statements.json')))
    if frozen != e2e:
        diff = sorted(k for k in set(frozen) | set(e2e) if frozen.get(k) != e2e.get(k))
        bad.append('memory_bench/law-statements.json differs from END_TO_END.bend laws: ' + ', '.join(diff))
    if '--update' in sys.argv[1:]:
        if bad:
            sys.exit('verify_frozen: ' + bad[0])
        with open(LOCK, 'w') as h:
            h.write(json.dumps(cur, indent=2, sort_keys=True) + '\n')
        print('frozen.lock.json sha256 ' + sha(open(LOCK, 'rb').read()))
        return
    lock = json.load(open(LOCK))
    for kind in ('files', 'statements'):
        for f in sorted(set(lock[kind]) | set(cur[kind])):
            if lock[kind].get(f) != cur[kind].get(f):
                bad.append('%s %s: %s, locked %s' % (kind, f, cur[kind].get(f, 'missing'), lock[kind].get(f, 'absent')))
    if bad:
        print('verify_frozen: MISMATCH against frozen.lock.json:\n  ' + '\n  '.join(bad))
        sys.exit(1)


if __name__ == '__main__':
    main()
