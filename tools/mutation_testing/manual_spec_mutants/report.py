#!/usr/bin/env python3
"""report.py INDEX.json RESULTS.json CORPUS.json NOTES.json > tables.md   (run on the server)
Classifies every fault (C) from the two verdicts and the hand-written notes (equivalence arguments, remarks) and prints the
per-rule tables and the totals as Markdown, plus tally.json next to the output."""
import collections, json, sys

idx = json.load(open(sys.argv[1]))
A = {r['id']: r for r in json.load(open(sys.argv[2]))}
B = {r['id']: r for r in json.load(open(sys.argv[3]))} if len(sys.argv) > 3 else {}
N = json.load(open(sys.argv[4])) if len(sys.argv) > 4 else {}
TITLES = {
 'u': 'uintN: little-endian, exact width, range, root chunk (4.1)', 'b': 'boolean (4.1, 4.2)',
 'v': 'Vector[T,N]: length', 'l': 'List[T,N]: limit, alignment, tail', 'bv': 'Bitvector[N]', 'bl': 'Bitlist[N]',
 'c': 'Containers: fixed part, first offset, offsets, variable parts (4.3, 4.8)', 'n': 'Unions (CompatibleUnion; plain Union is not instantiated in the 240 names)',
 'm': 'Merkleization: zero hashes, depth from the limit, packing, mix_in_length, container roots (4.6)',
 'p': 'Progressive types (4.5)', 'q': 'Lists and vectors of composite elements (4.2, 4.8)', 'f': 'Fulu names: byte vectors, attestation, hash message length',
 'z': 'Designed equivalent controls'}
def group(rule):
    p = rule.split('-')[0]
    for k in ('bv', 'bl'):
        if p.startswith(k):
            return k
    return p[0]
rows = collections.OrderedDict()
tally = collections.Counter()
detail = []
for f in idx:
    a = A.get(f['id'], {})
    b = B.get(f['id'])
    av = a.get('A', '?')
    bv = b['B'] if b else '-'
    note = N.get(f['id'], {})
    if av in ('KILLED', 'CRASH'):
        c = 'proofs'
    elif note.get('equivalent'):
        c = 'equivalent'
    elif bv == 'KILLED':
        c = 'corpus-only'
    elif av == 'SURVIVED' and bv == 'SURVIVED':
        c = 'neither'
    elif av == 'SURVIVED':
        c = 'survived-proofs (B not run)'
    else:
        c = av
    laws = ''
    for ch in a.get('checks', []):
        if ch['verdict'] in ('KILLED', 'CRASH'):
            laws = (', '.join(ch['laws']) or 'checker stack exhaustion') + ' (%s %s)' % (ch['type'], ch['op'])
    tally[c] += 1
    tally['A:' + av] += 1
    rows.setdefault(f['id'].split('/')[0], []).append((f, av, laws, bv, b, c, note))
    detail.append({'id': f['id'], 'A': av, 'B': bv, 'C': c})
json.dump({'total': len(idx), 'tally': tally, 'detail': detail}, open('tally.json', 'w'), indent=1)
last = None
for rule, lst in rows.items():
    g = group(rule)
    if g != last:
        print('\n### ' + TITLES.get(g, g) + '\n')
        last = g
    print('\nRule `%s`\n' % rule)
    print('| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | C |')
    print('|---|---|---|---|---|---|')
    for f, av, laws, bv, b, c, note in lst:
        bs = bv
        if b and b.get('B') in ('KILLED', 'SURVIVED'):
            bs = '%s (%d/%d cases, %d/%d vectors disagree)' % (b['B'], b['corpus_bad'], b['cases'], b['official_bad'], b['official'])
        asx = av + (': ' + laws if laws else '')
        if av == 'CRASH':
            asx = 'CRASH (checker stack exhaustion, no law named; the file does not check)'
        cx = c + ((' - ' + note['note']) if note.get('note') else '')
        print('| %s | %s | %s (`%s`) | %s | %s | %s |' % (f['id'], f['spec'], f['fault'], f['file'], asx, bs, cx))
print('\nTOTAL', json.dumps(dict(tally)), file=sys.stderr)
