#!/usr/bin/env python3
"""report.py DIR   (DIR holds index.json results.json corpus.json probe.json targeted.json recheck.json notes.json; run on the server)
Classifies every fault and prints the per-rule tables (Markdown) on stdout, the totals on stderr, and writes survivors.json and tally.json in DIR.

Verdicts per fault
  A  proofs:   KILLED (a named law fails), UNJUDGED (the checker exhausts its stack on the mutant even with the pinned settings of tools/check.sh:
               no verdict, not a detection), SURVIVED (ALL PROOFS CHECK on every checked facade)
  B  corpus:   KILLED / SURVIVED (reference corpus + official vectors of the representative types), TIMEOUT-ONLY
  B3 probe:    DISTINGUISHED / NO-DIFFERENCE (mutant against the unmutated program on offset, selector, truncation and byte mutations of valid cases)
  T  targeted: KILLED / SURVIVED (invalid-object cases of targeted/oinvalid2.bend)
Classification C
  proofs                      A KILLED
  unjudged+corpus             A UNJUDGED, B KILLED
  unjudged+probe              A UNJUDGED, B SURVIVED, B3 DISTINGUISHED  (a real decoder fault that only the probe sees)
  unjudged, no difference     A UNJUDGED, B and B3 found no difference (redundant check; argued in the note where possible)
  equivalent                  hand-argued behavior-preserving (notes.json)
  survivor                    A SURVIVED, not equivalent: verdict from notes.json (critical / gap-unreachable-through-api / corpus-gap-only)
"""
import collections, json, os, re, sys

D = sys.argv[1]
L = lambda n, d=None: json.load(open(os.path.join(D, n))) if os.path.exists(os.path.join(D, n)) else d
idx = L('index.json'); A = {r['id']: r for r in L('results.json')}; B = {r['id']: r for r in L('corpus.json', [])}
P = {r['id']: r for r in L('probe.json', [])}; T = {r['id']: r for r in L('targeted.json', [])}; RC = {r['id']: r for r in L('recheck.json', [])}
N = L('notes.json', {})
TITLES = {
 'u': 'uintN: little-endian, exact width, range, root chunk (SSZ 4.1)', 'b': 'boolean',
 'v': 'Vector[T,N]: length', 'l': 'List[T,N]: limit, alignment, tail', 'bv': 'Bitvector[N]', 'bl': 'Bitlist[N]',
 'c': 'Containers: fixed part, first offset, offsets, variable parts (4.3, 4.8)',
 'n': 'Unions (CompatibleUnion; a plain Union is not instantiated in the 240 names)',
 'm': 'Merkleization: zero hashes, depth from the limit, packing, mix_in_length, container roots (4.6)',
 'p': 'Progressive types (4.5)', 'q': 'Lists and vectors of composite elements (4.2, 4.8)',
 'f': 'Fulu names: byte vectors, attestation, hash message length', 's': '32-bit size limits', 'z': 'Designed equivalent controls'}


def group(rule):
    p = rule.split('-')[0]
    for k in ('bv', 'bl'):
        if p.startswith(k):
            return k
    return p[0]


def patch_info(fid):
    txt = open(os.path.join(D, 'patches', fid + '.patch')).read().split('\n')
    out, cur = [], None
    for l in txt:
        m = re.match(r'^@@ -(\d+),?\d* \+\d+,?\d* @@', l)
        if m:
            cur = {'line': int(m.group(1)), 'before': [], 'after': []}; out.append(cur)
        elif cur is not None and l.startswith('-') and not l.startswith('---'):
            cur['before'].append(l[1:])
        elif cur is not None and l.startswith('+') and not l.startswith('+++'):
            cur['after'].append(l[1:])
    return out


rows = collections.OrderedDict(); tally = collections.Counter(); surv = []; detail = []
for f in idx:
    i = f['id']; a = A.get(i, {}); av = a.get('A', '?')
    rc = RC.get(i)
    if av == 'CRASH':
        av = 'KILLED' if (rc and rc['pinned_verdict'] == 'KILLED') else ('SURVIVED' if (rc and rc['pinned_verdict'] == 'SURVIVED') else 'UNJUDGED')
    b = B.get(i); bv = b['B'] if b else '-'; p = P.get(i); pv = p['B3'] if p else '-'; t = T.get(i); tv = t['T'] if t else '-'
    note = N.get(i, {})
    if note.get('a_override'):
        av = note['a_override']
    if av == 'KILLED':
        c = 'proofs'
    elif note.get('equivalent'):
        c = 'equivalent'
    elif av == 'UNJUDGED':
        c = 'unjudged+corpus' if bv in ('KILLED', 'TIMEOUT-ONLY') else ('unjudged+probe' if pv == 'DISTINGUISHED' else 'unjudged, no difference found')
    elif av == 'SURVIVED':
        c = 'survivor: ' + note.get('verdict', 'critical' if (bv in ('KILLED', 'TIMEOUT-ONLY') or tv == 'KILLED') else 'neither')
    else:
        c = av
    tally[c] += 1; tally['A:' + av] += 1
    laws = ''
    for ch in a.get('checks', []):
        if ch['verdict'] == 'KILLED':
            laws = ', '.join(ch['laws']) + ' (%s %s)' % (ch['type'], ch['op'])
    if note.get('a_laws'):
        laws = note['a_laws']
    rows.setdefault(i.split('/')[0], []).append((f, av, laws, bv, b, pv, p, tv, c, note))
    detail.append({'id': i, 'A': av, 'B': bv, 'B3': pv, 'T': tv, 'C': c})
    if c.startswith('survivor') or c == 'unjudged+probe' or (note.get('verdict') and not note.get('equivalent') and av != 'KILLED'):
        surv.append({'id': i, 'file': f['file'], 'patch': patch_info(i), 'spec_rule': f['spec'], 'fault': f['fault'], 'types_checked': f['type'],
                     'A': av, 'B': bv, 'B3': pv, 'targeted': tv, 'targeted_flipped': (t or {}).get('flipped'),
                     'api_entry': note.get('api_entry'), 'counterexample_calls': note.get('counterexample_calls'),
                     'observable_result': note.get('observable_result'), 'reachability': note.get('reachability'),
                     'proofs_mentioning_the_mutated_code': note.get('proofs'), 'verdict': note.get('verdict', c)})
json.dump(surv, open(os.path.join(D, 'survivors.json'), 'w'), indent=1)
json.dump({'total': len(idx), 'tally': tally, 'detail': detail}, open(os.path.join(D, 'tally.json'), 'w'), indent=1)
last = None
for rule, lst in rows.items():
    g = group(rule)
    if g != last:
        print('\n### ' + TITLES.get(g, g) + '\n'); last = g
    print('\n`%s`\n' % rule)
    print('| id | spec rule violated | fault (patched file) | A proofs | B corpus + vectors | other | C |')
    print('|---|---|---|---|---|---|---|')
    for f, av, laws, bv, b, pv, p, tv, c, note in lst:
        bs = bv
        if b and b.get('B') in ('KILLED', 'SURVIVED'):
            bs = '%s (%d/%d cases, %d/%d vectors differ)' % (b['B'], b['corpus_bad'], b['cases'], b['official_bad'], b['official'])
        asx = av + (': ' + laws if laws else '')
        if av == 'UNJUDGED':
            asx = 'UNJUDGED (stack overflow of the checker with the pinned settings)'
        oth = []
        if pv != '-':
            oth.append('probe %s%s' % (pv, ' (%d inputs)' % p['inputs'] if p and p.get('inputs') else ''))
        if tv != '-':
            oth.append('targeted %s' % tv)
        cx = c + ((' - ' + note['note']) if note.get('note') else '')
        print('| %s | %s | %s (`%s`) | %s | %s | %s | %s |' % (f['id'], f['spec'], f['fault'], f['file'], asx, bs, '; '.join(oth) or '-', cx))
print('TOTAL', json.dumps(dict(tally)), file=sys.stderr)
