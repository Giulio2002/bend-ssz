#!/usr/bin/env python3
"""report12.py OUTDIR PKDIR DEST.json: round-12 survivors json from the proof results (res_p1a.json, res_p1d.json), the cache probe
(api_p12a.json) and the corpus (corpus12.json), with the judgements below. Run on the server.

Every fault that no named law killed gets an entry: verdict A (SURVIVED / UNJUDGED), the reachability argument (call chain from a
public entry point, or why none reaches the faulty line), a counter-example and the verdict:
critical / gap-unreachable / equivalent / corpus-gap-only / unjudged."""
import collections, json, os, re, sys

out, pk, dest = sys.argv[1:4]
R = {}
for f in ('res_p1a.json', 'res_p1d.json'):
    for r in json.load(open(os.path.join(out, f))):
        R[r['id']] = r
probe = {}
if os.path.exists(os.path.join(out, 'api_p12a.json')):
    probe = {k: v for k, v in json.load(open(os.path.join(out, 'api_p12a.json'))).items() if k != 'baseline'}
corpus = {}
if os.path.exists(os.path.join(out, 'corpus12.json')):
    d = json.load(open(os.path.join(out, 'corpus12.json')))
    for r in (d if isinstance(d, list) else d.values()):
        if isinstance(r, dict) and 'id' in r:
            corpus[r['id']] = r

J = {}
CACHE = ('critical',
         'public: X_append (or the list field of a decoded container: BeaconBlockBody.attester_slashings, '
         'ExecutionRequests.consolidations) -> X_cache(list) -> X_cache_at -> X_cache_sz -> X_cache_fin -> X_cached_root '
         '(the cached-tree API, types/runtime_index.json). No law caches a NON-EMPTY list of this kind: the kind has only the '
         'cache_app_* / cache_limit / cache_take laws, which start from X_cache(X_default()); the other kinds have cache_set_0 / '
         'cache_set_1_3 (cache of a 4-element list), which kill the same fault on them')
J['r12-d01-cache-lo/02'] = (CACHE[0], CACHE[1].replace('X_', 'l1_AttesterSlashing_'),
                           'probe p12a case 1: l1_AttesterSlashing_cache([AttesterSlashing_default()]) then cached_root = '
                           '3411617860,... while hash_tree_root of the same list = 3102059698,... (leaf 0 never hashed: the cached '
                           'root is the root of [zero chunk])')
J['r12-d01-cache-lo/03'] = (CACHE[0], CACHE[1].replace('X_', 'l2_ConsolidationRequest_'),
                           'probe p12a case 2: l2_ConsolidationRequest_cache([d, d]) then cached_root = 2493962254,... while '
                           'hash_tree_root = 23566629,...')
J['r12-d02-cache-depth0/03'] = (CACHE[0], CACHE[1].replace('X_', 'l2_ConsolidationRequest_') + ' (depth cap(0) = 0 for a 2-element list)',
                               'probe p12a case 2: l2_ConsolidationRequest_cache([d, d]) then cached_root = 2807177708,... while '
                               'hash_tree_root = 23566629,...')
J['r12-d02-cache-depth0/02'] = ('equivalent (in context)',
                               'List[AttesterSlashing, 1]: cap(n) = words_depth(n) is 0 for n = 0 and n = 1, the only lengths the list '
                               'can have, so cap(0) = cap(n)',
                               'none (probe p12a case 1: same line as the unmutated build)')
SER = ('gap-unreachable-through-api (contract gap: no law states X_serialize(invalid) = refused end to end)',
       'X_serialize -> X_senc_sized -> X_senc_go -> (mutant) X_putn instead of X_putk: the value\'s validity (X_valid) is no longer '
       'consulted on the serialize path. The facade has X_serialize_vreject_* (X_valid(bad) = False) and '
       'X_serialize_vrefuse_* (ser_done of a poisoned writer length is refused), but no law that X_serialize of an invalid value '
       'returns ok = False, so the wiring senc_go -> putk is not pinned. Every invalid value of this type the facade exhibits is '
       'built from a raw record (O.Words{Array.new(U32, 0n, 0), 5}: a length with no storage, or a list longer than its limit) '
       'that no public setter, append or decoder produces; through public calls only every value is valid and putn = putk.',
       '%s_serialize(%s): ok = True with bytes (spec / docs/API_CONTRACTS.md: refused); input needs a hand-built O.Words')
for i, t, v in (('01', 'CompatibleUnionBC', 'c1{ProgressiveVarTestStruct_set_f_B(default, O.Words{Array.new(U32, 0n, 0), 5})}'),
                ('02', 'CompatibleUnionABCA', 'c2{ProgressiveVarTestStruct_set_f_B(default, O.Words{Array.new(U32, 0n, 0), 5})}'),
                ('03', 'ProgressiveTestStruct', 'set_f_A(default, O.Words{Array.new(U32, 0n, 0), 5})'),
                ('04', 'ProgressiveVarTestStruct', 'set_f_B(default, O.Words{Array.new(U32, 0n, 0), 5})'),
                ('05', 'ProgressiveComplexTestStruct', 'set_f_A(default, O.Words{Array.new(U32, 0n, 0), 5})'),
                ('06', 'ProgressiveBitsStruct', 'a field set to a raw O.Bits / O.Words with no storage'),
                ('07', 'ProgressiveSingleListContainerTestStruct', 'set_f_C(default, raw O.Words with no storage)'),
                ('08', 'proglist_uint64', 'O.Words{Array.new(U32, 0n, 0), 8}')):
    J['r12-c02-ser-unchecked/' + i] = (SER[0], SER[1], SER[2] % (t, v))
VL = ('unjudged (proof: checker stack overflow twice at the pinned settings on every root that holds the file)',
      'BeaconState_decode -> BeaconState_ok -> l1099511627776_Validator_ok -> l1099511627776_Validator_ok_nz / _ck (the validators '
      'field window)')
J['r12-e02-vlist-ck/01'] = (VL[0] + '; refusal path', VL[1],
                           'BeaconState_decode of a state whose validators[0].slashed byte is 2 and which has >= 2 validators: accepted '
                           '(spec: rejected). No corpus case: no BeaconState under the corpus size cap; the valid-only corpus cannot reach a refusal')
J['r12-e02-vlist-ck/02'] = (VL[0], VL[1],
                           'BeaconState_decode of a valid state with >= 2 validators where byte 88 + 120 i of the list window (a byte of '
                           'validators[i-1].withdrawable_epoch... ) is > 1: rejected (spec: accepted); invalid slashed bytes past element 0 accepted')
J['r12-e02-vlist-ck/03'] = (VL[0] + '; refusal path', VL[1],
                           'BeaconState_decode with validators[0].slashed = 2: accepted (spec: rejected)')
BV = ('unjudged (proof: checker stack overflow twice on the decode facade; the first_offset law checks)',
      '%s_decode -> %s_ok -> %s_ok_at -> the bit vector field check at the neighbouring field\'s offset')
for i, t, ce in (('01', 'BitsStruct', 'BitsStruct_decode: B (Bitvector[2], byte 4) checked with the 1-bit rule, C (Bitvector[1], byte 5) unchecked: a valid value with B = 0x02 rejected, an invalid one with C = 0x02 accepted'),
                 ('02', 'BitsStruct', 'BitsStruct_decode: B (Bitvector[2], byte 4) padding unchecked (the 2-bit rule applied to C\'s byte 5, already held to the 1-bit rule): an invalid value with B = 0x04 accepted'),
                 ('03', 'ProgressiveBitsStruct', 'ProgressiveBitsStruct_decode: the Bitvector[257] padding byte checked one byte late (byte 41, inside the next field): valid values with that byte > 1 rejected, a non-zero padding byte 40 accepted'),
                 ('04', 'ProgressiveBitsStruct', 'ProgressiveBitsStruct_decode: the Bitvector[1281] padding checked at byte 248 (a data byte of the vector): valid values rejected, non-zero padding accepted')):
    J['r12-e03-bv-pad-pos/' + i] = (BV[0], BV[1] % (t, t, t), ce)

SPEC = lambda t: (re.search(r'^# spec: (.*)$', t, re.M) or [None, ''])[1]
rows = []
for i, r in sorted(R.items()):
    if r['A'] == 'KILLED':
        continue
    t = open(os.path.join(pk, i + '.patch')).read()
    j = J.get(i, ('unjudged', '', ''))
    ev = {'proofs': [(c['root'], c['verdict'], c['secs']) for c in r['checks']]}
    if i in probe:
        ev['probe_p12a'] = probe[i]
    if i in corpus:
        ev['corpus'] = corpus[i]
        if corpus[i].get('B') == 'KILLED' and j[0].startswith('unjudged'):
            j = ('corpus-gap-only (unjudged by the proofs; reachable: the corpus disagrees with the reference on %s cases)' % corpus[i].get('corpus_bad', '?'), j[1], j[2])
    rows.append({'id': i, 'patch': 'tools/mutation_testing/manual_spec_mutants/patches/%s.patch' % i, 'type': r.get('type'),
                 'file': r['file'], 'rule': SPEC(t), 'fault': (re.search(r'^# fault: (.*)$', t, re.M) or [None, ''])[1],
                 'A': r['A'], 'counterexample': j[2], 'reachability': j[1], 'verdict': j[0], 'evidence': ev})
json.dump(rows, open(dest, 'w'), indent=1)
print(len(rows), collections.Counter(x['verdict'].split(' (')[0] for x in rows))
