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
  - statement_defs: per file, the sha256 of every definition an end-to-end statement reaches,
    transitively, on the premise and the conclusion side (the views, rep invariants and their
    helpers, e2e/e2e_comp.bend's droot, and in src/ and types/ the helpers a statement names, such
    as B.fill_at, B.alloc, D.bytes, O.e8, the object types, and every def they reach), and of each
    statement file's statements themselves (signatures: hypotheses and conclusion). Not hashed: what
    is locked whole (above) and the implementation under test (SUBJECT: the generated per-name
    encoder, decoder and root, and the model API src/model.bend), which the proofs pin down. PLANTED
    changes (a premise-side src/ def, a def reached only transitively, an object type, and the
    encoder as the negative case) are run first on every invocation. The getters and setters in
    types/*_def_generated.bend that the object-mutation laws are about are hashed with the object
    types (they share the file), so changing one is a deliberate lock update. The statement files
    are codegen/statements.py's statement_files(): the bridges of e2e/manifest.json, the composed
    theorems e2e/*_e2e_comp_generated.bend, the witnesses e2e/*_e2e_witness_generated.bend, the
    validating serializer e2e/*_e2e_ser_generated.bend, the setter compositions e2e/*_e2e_set_generated.bend and the object-mutation laws
    (proofs/obj/coll_*, prep_setters*.bend and the swap laws of fields_*), found by name, so a new statement file
    fails this check until it is locked (--update).

tools/check_fast.sh runs this check before checking anything. The lock's own sha256 is printed
by --update; it is not written in README. The full check's stamp records it
(benchmarks/evidence/check_fast.json, "frozen_lock_sha256"), and `git log -p frozen.lock.json`
shows every change to it.
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
# Locked whole elsewhere (whole_files(), END_TO_END's statements), so not traversed:
WHOLE = ('spec/', 'vendor/', 'END_TO_END.bend')
# The implementation under test: what the statements are proved about. A change to these is what
# the proofs re-establish, so they are neither hashed nor traversed: the generated per-name
# encoder, decoder and root (pinned by the bridges) and the model API src/model.bend (pinned by
# END_TO_END's frozen laws).
SUBJECT = re.compile(r'^(src/model\.bend|types/\w+_(encode_ssz|decode_ssz|hashtreeroot)_generated\.bend)$')
# The exception to that carve-out: the validity predicates of the generated encoders and everything they call. They are not the
# implementation under test but the premise of the validating-serializer statements (e2e/*_e2e_ser_generated.bend:
# `X_valid(o) == True`), so a weakened predicate would weaken what those statements say. They are found by REACHABILITY, not by name:
# every def of an encode file reachable (through local names and imported ones, across the encode files) from a def named `*_valid`
# is hashed and traversed, whatever it is called (premise_reach). Excluded: the encoder entry points `*_encode` and `*_serialize`,
# which are the implementation under test even if a predicate named one.
ENTRY = re.compile(r'_(encode|serialize)$')
_mods = {}
_prc = {}
_override = {}  # path -> text, for the planted-change self-test only


def boundary(path, name=None):
    # the whole-locked types/ files (types/schema.bend, types/fulu_model.bend, ...) are not
    # traversed; proofs/obj/generic_specs.bend, locked whole too, still is (as before)
    if SUBJECT.match(path) and path.startswith('types/') and name is not None and (path, name) in premise_reach():
        return False
    return (path.startswith(WHOLE) or bool(SUBJECT.match(path))
            or (path in _whole_set() and path.startswith(('src/', 'types/'))))


_ws = []


def reset():
    _mods.clear()
    _prc.clear()


def premise_reach():
    """{(file, def)} of the encode files reachable from a `*_valid` def: the validity predicates and the helpers they call"""
    if 's' in _prc:
        return _prc['s']
    import glob
    files = sorted(set(os.path.relpath(f, ROOT) for f in glob.glob(os.path.join(ROOT, 'types/*_encode_ssz_generated.bend'))) | {k for k in _override if SUBJECT.match(k)})
    seen, todo = set(), []
    for f in files:
        todo += [(f, n) for n in module(f)[1] if n.endswith('_valid')]
    while todo:
        p, n = todo.pop()
        if (p, n) in seen or ENTRY.search(n):
            continue
        seen.add((p, n))
        imps, defs = module(p)
        text = defs[n]
        for m in REF.finditer(text):
            a, rest = m.group(1), m.group(2)
            if a in imps and SUBJECT.match(imps[a]) and os.path.exists(os.path.join(ROOT, imps[a])):
                parts = rest.split('.')
                tdefs = module(imps[a])[1]
                for k in range(len(parts), 0, -1):
                    if '.'.join(parts[:k]) in tdefs:
                        todo.append((imps[a], '.'.join(parts[:k])))
        for m in LOC.finditer(text):
            if m.group(1) in defs and m.group(1) != n:
                todo.append((p, m.group(1)))
    _prc['s'] = seen
    return seen


def _whole_set():
    if not _ws:
        _ws.append(set(whole_files()))
    return _ws[0]


def module(path):
    """(imports {alias: path}, defs {name: block text}) of a .bend file (comments dropped)"""
    if path not in _mods:
        imps, defs = {}, {}
        text = _override[path] if path in _override else open(os.path.join(ROOT, path)).read()
        for b in blocks(text):
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


def statement_defs(only=None):
    """{file: sha256} over every definition that a statement (codegen/statements.py
    statement_files()) reaches: its file-local defs and the imported defs they name, transitively,
    on the premise side and the conclusion side alike, in proofs/ and e2e/ and in src/ and types/
    (the buffer, digest and object helpers a statement names, B.fill_at, B.alloc, D.bytes, O.e8,
    the object types of types/*_def_generated.bend, and every def those reach). Not traversed: what
    is locked whole (spec/, vendor/, END_TO_END.bend, whole_files()) and the implementation under
    test (SUBJECT). A change to any hashed def changes what a statement says. `only` restricts
    the statement files (the self-test)."""
    sys.path.insert(0, os.path.join(ROOT, 'codegen'))
    import statements as ST
    sf = ST.statement_files()
    if only is not None:
        sf = {f: sf[f] for f in only}
    seen, todo, stmts = set(), [], {}
    for f in sorted(sf):
        laws = sf[f]
        path = f
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
            if boundary(tgt, name) or (tgt, name) in seen:
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


# Planted changes: (statement file, module, def, replacement block, must the hash change?).
# A premise-side src/ def (O.e8 in a Branch encode bridge's `cap` premise), a def reached only
# transitively through a conclusion-side src/ def (B.fill_go, through B.fill_at in a decode
# statement), an object type in types/*_def_generated.bend, and, as the negative case, the
# implementation under test (the encoder), whose change the proofs re-establish.
PLANTED = [
    ('e2e/FuluExecutionBranch_e2e_generated.bend', 'src/obj.bend', 'e8',
     'def e8(+i: Nat) -> Nat: 0n', True),
    ('e2e/FuluCheckpoint_e2e_dec_generated.bend', 'src/buffer.bend', 'fill_go',
     'def fill_go(xs: +List<U32>, ws: Array<U32>, +i: U32) -> Array<U32>: ws', True),
    ('e2e/FuluCheckpoint_e2e_generated.bend', 'types/FuluCheckpoint_def_generated.bend', 'Checkpoint',
     'type Checkpoint is Data:\n  Checkpoint{epoch: O.U64}', True),
    ('e2e/FuluCheckpoint_e2e_generated.bend', 'types/FuluCheckpoint_encode_ssz_generated.bend',
     'Checkpoint_encode', 'def Checkpoint_encode(o: C.Checkpoint) -> Nat: 0n', False),
    # the validity predicate of the validating serializer is premise-side: hashed (a serializer that
    # always refuses would otherwise pass with `valid` weakened or strengthened); the serializer
    # itself is the implementation under test, like the encoder
    ('e2e/FuluCheckpoint_e2e_ser_generated.bend', 'types/FuluCheckpoint_encode_ssz_generated.bend',
     'Checkpoint_valid', 'def Checkpoint_valid(o: C.Checkpoint) -> Bool: False{}', True),
    ('e2e/uint8_e2e_ser_generated.bend', 'types/uint8_encode_ssz_generated.bend',
     'u8_valid', 'def u8_valid(+o: U32) -> Bool: True{}', True),
    ('e2e/uint8_e2e_ser_generated.bend', 'types/uint8_encode_ssz_generated.bend',
     'uint8_serialize', 'def uint8_serialize(+o: U32) -> O.Encoded: O.refused()', False),
]


def self_test_helpers():
    """planting a change in any def a predicate calls, whatever its name, changes the statement's hash; a def no predicate reaches
    (the encoder's own helper) does not"""
    f = 'e2e/FuluCheckpoint_e2e_ser_generated.bend'
    path = 'types/FuluCheckpoint_encode_ssz_generated.bend'
    text = open(os.path.join(ROOT, path)).read()
    lines = text.split('\n')
    i = [k for k, l in enumerate(lines) if l.startswith('def Checkpoint_valid')][0]
    j = i + 1
    while j < len(lines) and (not lines[j].strip() or lines[j][0] in ' \t'):
        j += 1
    n = 0
    for h in ('va_cap', 'va_one', 'va_go', 'va_fin', 'va_nz', 'va_back', 'va7', 'chk', 'ok', 'va_cap2', 'va_x_y', 'va_Cap', 'va1_z'):
        hashes = []
        for body in ('True{}', 'False{}'):
            reset()
            _override[path] = '\n'.join(lines[:i] + ['def Checkpoint_valid(o: C.Checkpoint) -> Bool: Checkpoint_%s(o)' % h, '',
                                                     'def Checkpoint_%s(o: C.Checkpoint) -> Bool: %s' % (h, body), ''] + lines[j:])
            hashes.append(statement_defs([f]))
            _override.clear()
            reset()
        if hashes[0] == hashes[1]:
            sys.exit('verify_frozen: self-test FAILED: a change in the validity helper Checkpoint_%s does not change the hash of %s' % (h, f))
        n += 1
    # a def only the encoder calls is the implementation under test: no change of the hash
    hashes = []
    for body in ('Nat.add(1n, 1n)', 'Nat.add(2n, 2n)'):
        reset()
        _override[path] = '\n'.join(lines[:i] + lines[i:j] + ['def Checkpoint_enc_aux(o: C.Checkpoint) -> Nat: %s' % body, ''] + lines[j:])
        hashes.append(statement_defs([f]))
        _override.clear()
        reset()
    if hashes[0] != hashes[1]:
        sys.exit('verify_frozen: self-test FAILED: a def no predicate reaches changed the hash of %s' % f)
    n += 1
    return n


def self_test():
    n_helpers = self_test_helpers()
    for f, path, name, repl, must in PLANTED:
        reset()
        _override.clear()
        base = statement_defs([f])
        if name not in module(path)[1]:
            sys.exit('verify_frozen: self-test: %s has no def %s (update PLANTED)' % (path, name))
        text = open(os.path.join(ROOT, path)).read()
        blk = [b for b in blocks(text) if re.match(r'(?:def|law|type) %s\b' % re.escape(name), b[0])][0]
        lines = text.split('\n')
        i = lines.index(blk[0])
        j = i + 1
        while j < len(lines) and (not lines[j].strip() or lines[j][0] in ' \t'):
            j += 1
        _override[path] = '\n'.join(lines[:i] + [repl, ''] + lines[j:])
        reset()
        got = statement_defs([f])
        _override.clear()
        reset()
        if (got != base) != must:
            sys.exit('verify_frozen: self-test FAILED: planting %s.%s %s the hash of %s' % (
                path, name, 'did not change' if must else 'changed', f))
    return len(PLANTED) + n_helpers


def Path_(p):
    from pathlib import Path
    return Path(ROOT) / p


def compute():
    files = {f: sha(open(os.path.join(ROOT, f), 'rb').read()) for f in whole_files()}
    stm = {f: sha(statements(open(os.path.join(ROOT, f)).read()).encode()) for f in ROOTS}
    return {'files': files, 'statements': stm, 'statement_defs': statement_defs()}


def main():
    planted = self_test()
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
    print('verify_frozen: %d planted changes ok; %d files, %d statement roots, %d statement_defs files match'
          % (planted, len(cur['files']), len(cur['statements']), len(cur['statement_defs'])))


if __name__ == '__main__':
    main()
