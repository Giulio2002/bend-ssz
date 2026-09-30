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
  - memory_bench/law-statements.json must hold exactly END_TO_END.bend's law blocks, verbatim;
  - types/fulu_model.bend (the typed Fulu model and index END_TO_END's per-name laws use) and
    proofs/obj/generic_specs.bend (the schemas of the 131 generic names), whole;
  - statement_defs: per file, the sha256 of every definition a bridge statement (e2e/manifest.json)
    reaches outside src/, types/, spec/ and vendor/ (the views, rep invariants and their helpers),
    and of each bridge file's statements themselves (signatures: hypotheses and conclusion).

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
    # what the laws and bridges quantify over: the Fulu typed model and index END_TO_END's per-name
    # laws use, and the generic schemas every generic-name bridge is stated against
    fs += ['types/fulu_model.bend', 'proofs/obj/generic_specs.bend']
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


# ---- the definitions the bridge statements depend on ----
BOUNDARY = ('src/', 'types/', 'spec/', 'vendor/', 'END_TO_END.bend')
_mods = {}


def module(path):
    """(imports {alias: path}, defs {name: block text}) of a .bend file (comments dropped)"""
    if path not in _mods:
        imps, defs = {}, {}
        for b in blocks(open(os.path.join(ROOT, path)).read()):
            m = re.match(r'import (\S+) as (\w+)', b[0])
            if m:
                imps[m.group(2)] = os.path.normpath(os.path.join(os.path.dirname(path), m.group(1)))
                continue
            m = re.match(r'(?:def|law|type) ([A-Za-z_][\w.]*)', b[0])
            if m:
                defs[m.group(1)] = '\n'.join(b)
        _mods[path] = (imps, defs)
    return _mods[path]


REF = re.compile(r'(?<![\w.])([A-Za-z_]\w*)\.([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)')
LOC = re.compile(r'(?<![\w.])([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)')


def statement_defs():
    """{file: sha256} over every definition, outside the boundary (src/, types/, spec/, vendor/,
    END_TO_END.bend: the implementation under test, and what is locked whole), that a bridge
    statement of e2e/manifest.json reaches: its file-local defs and the imported defs they name,
    transitively. A change to any of them changes what a bridge statement says."""
    sys.path.insert(0, os.path.join(ROOT, 'codegen'))
    import statements as ST
    man = json.load(open(os.path.join(ROOT, 'e2e/manifest.json')))
    seen, todo, stmts = set(), [], {}
    for f in sorted(man['files']):
        laws = [l for e in man['files'][f] for l in e['laws']]
        path = 'e2e/' + f
        imps_, local, stm = ST.file_statements(Path_(path), laws)
        todo.append((path, '\n'.join(local + stm), set(laws)))
        stmts[path] = '\n'.join(stm)
    while todo:
        path, text, skip = todo.pop()
        imps, defs = module(path)
        refs = []
        for m in REF.finditer(text):
            a, rest = m.group(1), m.group(2)
            if a in imps:
                parts = rest.split('.')
                for k in range(len(parts), 0, -1):
                    refs.append((imps[a], '.'.join(parts[:k])))
        for m in LOC.finditer(text):
            if m.group(1) in defs and m.group(1) not in skip:
                refs.append((path, m.group(1)))
        for tgt, name in refs:
            if tgt.startswith(BOUNDARY) or (tgt, name) in seen:
                continue
            if not os.path.exists(os.path.join(ROOT, tgt)):
                continue
            tdefs = module(tgt)[1]
            if name not in tdefs:
                continue
            seen.add((tgt, name))
            head = tdefs[name].split('\n')[0]
            if head.startswith('def ') and '->' not in head:
                continue  # the proof of a law (untyped binders): its statement is the law block
            todo.append((tgt, tdefs[name], set()))
    per = {path: ['\0statements\0' + t] for path, t in stmts.items()}
    for tgt, name in sorted(seen):
        per.setdefault(tgt, []).append(name + '\0' + module(tgt)[1][name])
    return {f: sha('\n'.join(v).encode()) for f, v in per.items()}


def Path_(p):
    from pathlib import Path
    return Path(ROOT) / p


def compute():
    files = {f: sha(open(os.path.join(ROOT, f), 'rb').read()) for f in whole_files()}
    stm = {f: sha(statements(open(os.path.join(ROOT, f)).read()).encode()) for f in ROOTS}
    return {'files': files, 'statements': stm, 'statement_defs': statement_defs()}


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
    for kind in ('files', 'statements', 'statement_defs'):
        for f in sorted(set(lock[kind]) | set(cur[kind])):
            if lock[kind].get(f) != cur[kind].get(f):
                bad.append('%s %s: %s, locked %s' % (kind, f, cur[kind].get(f, 'missing'), lock[kind].get(f, 'absent')))
    if bad:
        print('verify_frozen: MISMATCH against frozen.lock.json:\n  ' + '\n  '.join(bad))
        sys.exit(1)


if __name__ == '__main__':
    main()
