#!/usr/bin/env python3
"""mk_patches.py TREE DEFS_DIR OUT_DIR: materialise the hand-written fault definitions (defs/*.txt) as unified diffs.

A definition block starts with '=== <rule-slug>' and has header lines 'key: value' (type, ops, file, spec, why, fault),
then diff lines: '-<old text>' and '+<new text>'. A run of '-' lines followed by '+' lines is one hunk; the old text must
occur exactly once in the file (or exactly `count: N` times, all of which are replaced). Output: OUT_DIR/<rule-slug>/<NN>.patch
(a `patch -p1` diff with a '#'-header carrying the metadata) and OUT_DIR/index.json. Run on the server, never on a laptop.
"""
import difflib, json, os, re, sys, glob

tree, defs, out = sys.argv[1:4]
blocks = []
for f in sorted(glob.glob(os.path.join(defs, 'r3_*.txt'))):
    cur = None
    for line in open(f).read().split('\n'):
        if line.startswith('==='):
            cur = {'rule': line[3:].strip(), 'hunks': [], 'src': os.path.basename(f)}
            blocks.append(cur)
            continue
        if cur is None or line.startswith('##'):
            continue
        if line[:1] in '-+' and line[:1] != '':
            kind = line[0]
            h = cur['hunks']
            if kind == '-':
                if not h or h[-1]['new']:
                    h.append({'old': [], 'new': []})
                h[-1]['old'].append(line[1:])
            else:
                if not h:
                    raise SystemExit('plus line before minus in %s' % cur['rule'])
                h[-1]['new'].append(line[1:])
        elif re.match(r'^[a-z_]+:', line):
            k, v = line.split(':', 1)
            cur[k] = v.strip()
cnt, index, bad = {}, [], 0
for b in blocks:
    rule = b['rule']
    cnt[rule] = cnt.get(rule, 0) + 1
    n = cnt[rule]
    fid = '%s/%02d' % (rule, n)
    path = os.path.join(tree, b['file'])
    text = open(path).read()
    new = text
    for h in b['hunks']:
        old = '\n'.join(h['old'])
        rep = '\n'.join(h['new'])
        want = int(b.get('count', '1'))
        if new.count(old) != want:
            print('BAD %s: old text occurs %d times (want %d): %s' % (fid, new.count(old), want, old[:100]))
            bad += 1
            break
        new = new.replace(old, rep)
    else:
        if new == text:
            print('NOOP', fid); bad += 1; continue
        hdr = ['# MANUAL SPEC MUTANT %s' % fid]
        for k in ('type', 'ops', 'spec', 'fault', 'why', 'file', 'sym', 'proofs', 'base'):
            if k in b:
                hdr.append('# %s: %s' % (k, b[k]))
        diff = list(difflib.unified_diff(text.split('\n'), new.split('\n'), 'a/' + b['file'], 'b/' + b['file'], lineterm='', n=1))
        os.makedirs(os.path.join(out, rule), exist_ok=True)
        open(os.path.join(out, rule, '%02d.patch' % n), 'w').write('\n'.join(hdr + diff) + '\n')
        index.append({'id': fid, **{k: b.get(k) for k in ('type', 'ops', 'spec', 'fault', 'why', 'file', 'sym', 'proofs', 'base')}})
json.dump(index, open(os.path.join(out, 'index.json'), 'w'), indent=1)
print('faults', len(index), 'bad', bad)
sys.exit(1 if bad else 0)
