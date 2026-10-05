#!/usr/bin/env python3
"""report11.py OUTDIR PKDIR TREE DEST.json: round-11 survivors json from the pass-1 / pass-2 proof results (res_p1.json, res_p2.json),
the probe (api_p11a.json) and the corpus (corpus11A.json, corpus11B.json, corpus11.json), with the judgements below. Run on the server.

Every fault that no named law killed gets an entry: verdict A (SURVIVED / UNJUDGED), the reachability argument (call chain from a
public entry point, or why no public entry point reaches the faulty line), a counter-example and the verdict:
critical / gap-unreachable / equivalent / corpus-gap-only / unjudged."""
import json, os, re, sys

out, pk, tree, dest = sys.argv[1:5]
R = {r['id']: r for r in json.load(open(os.path.join(out, 'res_p1.json')))}
if os.path.exists(os.path.join(out, 'res_p2.json')):
    for r in json.load(open(os.path.join(out, 'res_p2.json'))):
        old = R[r['id']]
        r['checks'] = old['checks'] + r['checks']
        if r['A'] != 'KILLED' and old['A'] == 'UNJUDGED':
            r['A'] = 'UNJUDGED'
        R[r['id']] = r
probe = json.load(open(os.path.join(out, 'api_p11a.json'))) if os.path.exists(os.path.join(out, 'api_p11a.json')) else {}
corpus = {}
for f in ('corpus11.json', 'corpus11A.json', 'corpus11B.json'):
    p = os.path.join(out, f)
    if os.path.exists(p):
        d = json.load(open(p))
        for r in (d if isinstance(d, list) else d.values()):
            if isinstance(r, dict) and 'id' in r:
                corpus[r['id']] = r

TOP = ('equivalent (in context)',
       'X_read is called only by X_decode / X_build of its own file with off = 0 (no X_bx_read or X_read caller in types/ or src/: grep); '
       'at off = 0 the absolute and the rebased offsets coincide',
       'none: every public path reads this container at offset 0')
DEAD = ('equivalent (in context: dead code)',
        'the mutated validator has no caller in types/ or src/ (grep: the only occurrence is its definition); containers validate this '
        'field kind with X_ok_at (fixed window) and the kind has no public X_decode of its own',
        'none: no public entry point reaches the faulty line')
J = {}
for i in ('01', '02', '03', '04', '13', '14', '15', '16', '17', '18', '19', '20', '22'):
    J['r11-a01-reader-base/' + i] = TOP
for i in range(1, 16):
    J['r11-b01-ok-len/%02d' % i] = DEAD
for i in ('02', '03', '05', '06', '07', '08'):
    J['r11-b03-bx-ok/' + i] = DEAD
for i in ('09', '10', '11', '12'):
    J['r11-a01-reader-base/' + i] = (
        'unjudged (proof: stack overflow on every facade that reaches it); reachable, the corpus shows wrong answers',
        'ExecutionPayload_gK_read is reached with off != 0 through BeaconBlockBody_decode -> BeaconBlockBody_g1_read -> '
        'FuluExecutionPayload_r.ExecutionPayload_bx_read(buf, off + o_execution_payload, ...) -> ExecutionPayload_read -> ExecutionPayload_gK_read '
        '(also BeaconBlock_decode, SignedBeaconBlock_decode)',
        'BeaconBlockBody_decode(bytes of any valid body): the execution payload field is read from the absolute byte instead of '
        'the payload\'s own window (any body; the payload starts at offset >= 396)')
J['r11-b03-bx-ok/01'] = ('unjudged (refusal path)',
                        'BeaconBlockBody_decode -> l1_AttesterSlashing_ok (list element windows) -> AttesterSlashing_bx_ok: the element\'s own '
                        'validity check is skipped',
                        'BeaconBlockBody_decode of a body whose attester_slashings element has a bad inner offset: accepted (spec: rejected)')
J['r11-b03-bx-ok/09'] = ('unjudged (refusal path; argued critical only for inputs over 2^30 bytes)',
                        'ExecutionPayload_decode -> l1048576_bl1073741824_ok -> bl1073741824_bx_ok (each transaction window)',
                        'ExecutionPayload_decode with a transaction longer than 2^30 bytes cannot be built under the size cap; a ByteList '
                        'element has no other validity condition, so the skipped check only matters for the limit')
J['r11-b03-bx-ok/10'] = ('unjudged (refusal path)',
                        'ProgressiveComplexTestStruct_decode / CompatibleUnionBC_decode -> pl_ProgressiveVarTestStruct_ok -> ProgressiveVarTestStruct_bx_ok',
                        'decode of a ProgressiveComplexTestStruct whose ProgressiveVarTestStruct element has a bad inner offset: accepted')
J['r11-b03-bx-ok/11'] = ('unjudged (refusal path)',
                        'ComplexTestStruct_decode / ProgressiveTestStruct_decode -> v2_VarTestStruct_ok / pl_VarTestStruct_ok -> VarTestStruct_bx_ok',
                        'ComplexTestStruct_decode with a VarTestStruct element whose offset is past its window: accepted')
J['r11-b03-bx-ok/12'] = ('unjudged (refusal path)',
                        'ProgressiveTestStruct_decode -> pl_pl_VarTestStruct_ok -> pl_VarTestStruct_bx_ok',
                        'decode with a nested progressive list element whose inner offsets are bad: accepted')
J['r11-c01-group-acc/05'] = ('gap-unreachable (through the API)',
                            'BeaconState_serialize / _encode -> BeaconState_valid_f -> BeaconState_g2_valid: with the accumulator dropped only '
                            'next_sync_committee\'s validity counts; the other validated fields of g2 (current_epoch_participation, '
                            'inactivity_scores: limit 2^40 > any U32 count; justification_bits: padding bits; current_sync_committee: storage '
                            'length) can be invalid only through a raw value (a Bitvector4 word with bits 4..31 set, an O.Words of the wrong '
                            'length) that no public setter writes',
                            'BeaconState with justification_bits = Bitvector4{0xF0} (raw constructor): serialize answers ok (spec: invalid). '
                            'No law kills it: the facade has vreject laws for g0, g1, g3, g4 fields but none for a g2 field before the last')
for i in ('08', '09', '10'):
    J['r11-c01-group-acc/' + i] = ('equivalent',
                                  'the group validates exactly one field (logs_bloom / extra_data): the accumulator passed to the last step is the '
                                  'literal True{}, so Bool.and(True{}, ok) = ok',
                                  'none')
CACHE_GROW = ('critical',
              'public: X_cache(X_default()) then X_capp five times, then X_cached_root (the cached-tree API, docs/API_CONTRACTS.md); the '
              'growth branch of X_capp_fit runs at n = 1, 2, 4; at n = 4 -> 5 (depth 2 -> 3) leaves 5..7 and node 7 are never swept',
              'probe p11a case 1 (List[Attestation, 8]): cached root differs from hash_tree_root(uncache(c))')
J['r11-d02-cache-grow-window/03'] = CACHE_GROW
for i, nm in (('01', 'List[ProposerSlashing, 16]'), ('02', 'List[Deposit, 16]'), ('05', 'transactions'), ('06', 'List[ProgressiveSingleFieldContainerTestStruct, 10]')):
    J['r11-d02-cache-grow-window/' + i] = ('critical' if i != '01' and i != '02' else 'critical (argued: the generated code is identical to d02/03, which the probe demonstrates; the probe has no case for this list; the proofs timed out (unjudged) on the body root facade for 01 and 02)', CACHE_GROW[1],
                                          '%s: cache(default), capp x5, cached_root != plain root (same generated code as d02/03; probe cases 2 and 3 for '
                                          'transactions and the l10 list)' % nm)
J['r11-d02-cache-grow-window/04'] = ('equivalent (in context)',
                                    'List[AttesterSlashing, 1]: capp admits only n = 0, where the depth-0 tree has room (pow2(0) = 1 > 0); the growth '
                                    'branch never runs', 'none')
J['r11-d03-cset-lo/04'] = ('critical', 'l1_AttesterSlashing_cache -> cached_root (window reset to (n, 0) = (1, 0)) -> cset(0, v): lo stays 1 > hi = 0, the sweep is skipped',
                          'probe p11a case 4: [default] -> cache, root, cset(0, slashing with slot 7): cached root = the old root')
J['r11-d03-cset-lo/05'] = ('critical', 'transactions: cache -> cached_root -> cset(0, tx): lo stays 2 > hi = 0, no rehash',
                          'probe p11a case 5: [01, 02] -> cset(0, [03]): cached root stale')
J['r11-d04-cset-hi/03'] = ('critical', 'transactions: cache -> cached_root -> cset(1, tx): hi stays 0 < lo = 1, no rehash',
                          'probe p11a case 6: [01, 02] -> cset(1, [03]): cached root stale')
J['r11-d05-cache-depth/04'] = ('equivalent (in context)', 'l1_AttesterSlashing_cache_sz clamps the depth with O.cache_dok(pow2(d) <= storage slots): a List[AttesterSlashing, 1] holds at most 1 slot (append and decode size the storage by capacity(n) = 0), so the depth-1 request falls back to 0', 'none (probe p11a case 7: same line)')
J['r11-d06-capp-lo/01'] = ('equivalent (in context)',
                          'the window\'s low end is n after X_cached_root (croot_fin) and 0 after X_cache; every update keeps lo <= n, so '
                          'min(lo, n) = lo whenever capp runs', 'none (probe p11a case 8: same line)')
J['r11-d07-croot-reset/01'] = ('equivalent',
                              'the reset window (0, 0) rehashes leaf 0 (or stores the zero chunk at slot 2^d when n = 0) on the next root: the '
                              'same digest is rewritten, every other node is unchanged', 'none (probe p11a case 8: same line)')
J['r11-e02-prog-len/01'] = ('equivalent', 'U32.shrn(n, 3) = U32.div(n, 8) for every U32', 'none')
J['r11-e02-prog-len/02'] = ('equivalent (in context)',
                           'the byte length of a proglist_uint128 is always a multiple of 16: pl_u128_ok refuses len mod 16 != 0, '
                           'pl_u128_default is empty and append grows by 16', 'none')
J['r11-f01-union-same-type/02'] = ('unjudged (proof: stack overflow); reachable, probe p11a and the corpus show the wrong answer',
                                  'CompatibleUnionABCA_decode(bytes with selector 4) -> CompatibleUnionABCA_rd3 builds option c0',
                                  'probe p11a case 9: serialize(c3{default}) then decode: selector 1 instead of 4')

SPEC = lambda t: (re.search(r'^# spec: (.*)$', t, re.M) or [None, ''])[1]
rows = []
for i, r in sorted(R.items()):
    if r['A'] == 'KILLED':
        continue
    t = open(os.path.join(pk, i + '.patch')).read()
    j = J.get(i, ('unjudged', '', ''))
    ev = {'proofs': [(c['root'], c['verdict'], c['secs']) for c in r['checks']]}
    if i in probe:
        ev['probe_p11a'] = probe[i]
    if i in corpus:
        ev['corpus'] = corpus[i]
        if corpus[i].get('B') == 'KILLED' and j[0].startswith('unjudged') and 'corpus' not in j[0]:
            j = (j[0] + '; reachable: the corpus disagrees with the reference on %s cases' % corpus[i].get('corpus_bad', '?'), j[1], j[2])
    if i in probe and probe[i].get('B2') == 'KILLED' and 'probe' not in j[0]:
        j = (j[0] + '; probe p11a prints a different line', j[1], j[2])
    rows.append({'id': i, 'patch': 'tools/mutation_testing/manual_spec_mutants/patches/%s.patch' % i, 'type': r.get('type'),
                 'file': r['file'], 'rule': SPEC(t), 'fault': (re.search(r'^# fault: (.*)$', t, re.M) or [None, ''])[1],
                 'A': r['A'], 'counterexample': j[2], 'reachability': j[1], 'verdict': j[0], 'evidence': ev})
json.dump(rows, open(dest, 'w'), indent=1)
import collections
print(len(rows), collections.Counter(x['verdict'] for x in rows))
