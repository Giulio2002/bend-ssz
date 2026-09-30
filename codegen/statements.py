#!/usr/bin/env python3
"""e2e/STATEMENTS.txt: every end-to-end statement, in one reviewable file.

    python3 codegen/statements.py [--check]

The statement files (statement_files()): every bridge file of e2e/manifest.json, every composed file
e2e/<Name>_e2e_comp_generated.bend (its <Name>_e2e_decode_encode and <Name>_e2e_decode_root:
decoding then re-encoding gives the input, decoding then hashing gives the spec root), every
non-vacuity witness e2e/<Name>_e2e_witness_generated.bend (<Name>_e2e_witness and, when present,
<Name>_e2e_witness_nonempty), every setter composition e2e/<Name>_e2e_set_generated.bend
(codegen/e2e_setters.py: a setter then root or encode gives the spec's), and the object-mutation
laws of OBJECT_LAWS: the field laws proofs/obj/fields_*.bend (read after write, overwrite,
unchanged fields), the collection laws proofs/obj/collections_*.bend (rejected and accepted writes
and appends) and the setter laws proofs/obj/prep_setters.bend (a setter keeps rep); for these,
every def whose result is an equality proposition and every `law` block is a statement. Found by name, so a new composed or witness file is listed (and, through
tools/verify_frozen.py's statement_defs, must be locked) without any edit here. For each (sorted),
writes the statements of its laws
(the signature of each def the manifest lists: its hypotheses and conclusion, no proof), the
file-local defs those statements use (whole: they are part of what the statement says), and the
imports whose aliases they use. A reviewer reads this file, END_TO_END.bend's laws and the spec;
nothing else decides what the object API is proved to do. The proofs stay in the e2e files, and
the full check (tools/check_fast.sh) checks those files, so every statement listed here is checked.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'e2e/STATEMENTS.txt'
DEF = re.compile(r'def ([A-Za-z_][\w.]*)')


def blocks(text):
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


def signature(b):
    sig = []
    for l in b:
        sig.append(l)
        if l.endswith(':'):
            break
    return sig


def file_statements(path, laws):
    bs = blocks(path.read_text())
    defs, lawb = {}, {}
    for b in bs:
        m = DEF.match(b[0])
        if m:
            defs[m.group(1)] = b
        m = re.match(r'law (\S+):', b[0])
        if m:
            lawb[m.group(1)] = b
    stm = []
    for law in laws:
        if law in lawb:  # a `law` block is its own statement (its def is the proof)
            stm.append('\n'.join(lawb[law]))
            continue
        if law not in defs:
            sys.exit('statements: %s: law %s not found' % (path.name, law))
        stm.append('\n'.join(signature(defs[law])))
    # file-local defs the statements use, transitively (not the laws' own proofs)
    used, todo = [], ['\n'.join(stm)]
    while todo:
        t = todo.pop()
        for name, b in defs.items():
            if name in laws or name in used:
                continue
            if re.search(r'(?<![\w.])%s\(' % re.escape(name), t):
                used.append(name)
                todo.append('\n'.join(b))
    local = ['\n'.join(defs[n]) for n in sorted(used)]
    text = '\n'.join(local + stm)
    imps = []
    for b in bs:
        m = re.match(r'import (\S+) as (\w+)', b[0])
        if m and re.search(r'(?<![\w.])%s\.' % re.escape(m.group(2)), text):
            imps.append(b[0])
    return imps, local, stm


# the object-mutation laws (codegen/laws.py, codegen/rep_laws.py): every statement of these files
OBJECT_LAWS = ['proofs/obj/fields_*.bend', 'proofs/obj/collections_*.bend', 'proofs/obj/prep_setters.bend']


def eq_defs(text):
    """the defs of a law file whose result is an equality proposition (their signature is the
    statement), and its `law` blocks, in file order"""
    out = []
    for b in blocks(text):
        m = re.match(r'law (\S+):', b[0])
        if m:
            out.append(m.group(1))
            continue
        m = DEF.match(b[0])
        if m and m.group(1) not in out and re.search(r'-> \{.*\}:$', ' '.join(signature(b))):
            out.append(m.group(1))
    return out


def statement_files():
    """{root-relative path: [law names]}: the bridges (e2e/manifest.json), the composed theorems,
    the witnesses, the setter compositions (e2e/*_e2e_set_generated.bend) and the object-mutation
    laws (OBJECT_LAWS)"""
    man = json.loads((ROOT / 'e2e/manifest.json').read_text())
    out = {'e2e/' + f: [l for e in man['files'][f] for l in e['laws']] for f in man['files']}
    for p in sorted((ROOT / 'e2e').glob('*_e2e_comp_generated.bend')):
        n = p.name[:-len('_e2e_comp_generated.bend')]
        out['e2e/' + p.name] = [f'{n}_e2e_decode_encode', f'{n}_e2e_decode_root']
    for p in sorted((ROOT / 'e2e').glob('*_e2e_witness_generated.bend')):
        n = p.name[:-len('_e2e_witness_generated.bend')]
        t = p.read_text()
        out['e2e/' + p.name] = [l for l in (f'{n}_e2e_witness', f'{n}_e2e_witness_nonempty', f'{n}_e2e_witness_root',
                                            f'{n}_e2e_witness_root_nonempty') if re.search(r'^def %s\(' % l, t, re.M)]
    for p in sorted((ROOT / 'e2e').glob('*_e2e_set_generated.bend')):
        out['e2e/' + p.name] = re.findall(r'^def (\w+_e2e_set_\w+)\(', p.read_text(), re.M)
    for g in OBJECT_LAWS:
        for p in sorted(ROOT.glob(g)):
            out[str(p.relative_to(ROOT))] = eq_defs(p.read_text())
    return out


def render():
    out = ['# GENERATED by codegen/statements.py. Do not edit.',
           '# Every end-to-end statement: the bridges (e2e/manifest.json), the composed decode;encode and',
           '# decode;root theorems (e2e/*_e2e_comp_generated.bend), the non-vacuity witnesses',
           '# (e2e/*_e2e_witness_generated.bend), the setter compositions (e2e/*_e2e_set_generated.bend) and',
           '# the object-mutation laws (proofs/obj/fields_*, collections_*, prep_setters.bend), with the',
           '# imports and file-local defs they use; the proofs are in the named files, which',
           '# tools/check_fast.sh checks.', '']
    n = 0
    sf = statement_files()
    for f in sorted(sf):
        laws = sf[f]
        imps, local, stm = file_statements(ROOT / f, laws)
        out.append('## ' + f)
        out += imps
        out += local
        out += stm
        out.append('')
        n += len(stm)
    out.insert(7, '# %d statements in %d files.' % (n, len(sf)))
    return '\n'.join(out) + '\n'


def main():
    text = render()
    if '--check' in sys.argv[1:]:
        if not OUT.exists() or OUT.read_text() != text:
            print('statements: e2e/STATEMENTS.txt is stale (run python3 codegen/statements.py)')
            sys.exit(1)
        return
    OUT.write_text(text)


if __name__ == '__main__':
    main()
