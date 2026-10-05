#!/usr/bin/env python3
"""report10.py OUTDIR PKDIR OUT.json: merge the round-10 verdicts and write manual_round_10_survivors.json. Run on the server.

Verdict (A) per fault: the last pass that ran it wins (res_p2 > res_h3 > res_p1h > res_p1); h03 faults are judged only by res_h3
(the first h03 instances did not typecheck: a linear digest used twice; they were replaced and are not counted).
Rows: every fault the proofs did not kill (SURVIVED and UNJUDGED), with the probe (api_p10a) and corpus (corpus10*) evidence and the
judgement inputs (JUDGE below). Also prints the summary counts per family."""
import collections, glob, json, os, re, sys

out, pk, dst = sys.argv[1:4]


def load(n):
    p = os.path.join(out, n)
    return json.load(open(p)) if os.path.exists(p) else []


final = {}
for n in ('res_p1.json', 'res_p1h.json', 'res_h3.json', 'res_p2.json'):
    for r in load(n):
        if r['id'].startswith('r10-h03') and n != 'res_h3.json':
            continue
        final[r['id']] = dict(r, src=n)
probe = {}
if os.path.exists(os.path.join(out, 'api_p10a.json')):
    probe = {k: v for k, v in json.load(open(os.path.join(out, 'api_p10a.json'))).items() if k != 'baseline'}
corpus = {}
for p in sorted(glob.glob(os.path.join(out, 'corpus10*.json'))):
    for r in json.load(open(p)):
        corpus[r['id']] = r


def hdr(fid):
    h = {}
    for l in open(os.path.join(pk, fid + '.patch')):
        if not l.startswith('#'):
            break
        m = re.match(r'# (\w+): (.*)', l)
        if m:
            h[m.group(1)] = m.group(2).strip()
    return h


# Judgement inputs for the default-constructor survivors (r10-d01): public call, spec rule, reachability.
DEF_CALLS = {
    '01': ('Bytes20_serialize(b20_default()) / Withdrawal_serialize(Withdrawal_default()) (address field)', 'FuluBytes20 (ExecutionAddress)'),
    '02': ('Checkpoint_serialize(Checkpoint_default()), Bytes32_serialize(b32_default())', 'FuluBytes32 (Root, Hash32: every root field of every Fulu container)'),
    '03': ('Bytes48_serialize(b48_default()), SyncCommittee_serialize(SyncCommittee_default()) (aggregate_pubkey)', 'FuluBytes48 (BLSPubkey, KZGCommitment, KZGProof)'),
    '04': ('Bytes8_serialize(b8_default())', 'FuluBytes8'),
    '05': ('Bytes96_serialize(b96_default()), Attestation_serialize(Attestation_default()) (signature)', 'FuluBytes96 (BLSSignature)'),
    '09': ('SyncCommitteeContribution_serialize(SyncCommitteeContribution_default()) (aggregation_bits)', 'Fulu_bitvector_128'),
    '10': ('BeaconState_serialize(BeaconState_default()) (justification_bits)', 'Fulu_bitvector_4'),
    '11': ('SyncAggregate_serialize(SyncAggregate_default()) (sync_committee_bits)', 'Fulu_bitvector_512'),
    '12': ('Attestation_serialize(Attestation_default()) (committee_bits)', 'Fulu_bitvector_64'),
    '20': ('bitvector_513_serialize(bv513_default())', 'bitvector_513'),
    '21': ('bitvector_5_serialize(bv5_default())', 'bitvector_5'),
    '22': ('boolean_serialize(bool_default())', 'boolean'),
    '23': ('uint64_serialize(u64_default()), Checkpoint_serialize(Checkpoint_default()) (epoch)', 'uint64 (Slot, Epoch, Gwei, every index)'),
}
PROBE_CASE = {'01': '1', '02': '2', '03': '3', '04': '4', '05': '5', '09': '6', '11': '7', '12': '8', '20': '10', '21': '9', '22': '11', '23': '12'}

NOTE = {
    'r10-w03-size-fixed-part/01': 'equivalent in context: BitsStruct_encode / _serialize size the output with the writer cursor (O.out_at(2n) + out_donem(m)); BitsStruct_size has no caller in types/ or src/ (grep), so no public entry point reaches the mutated constant',
    'r10-w03-size-fixed-part/16': 'equivalent in context: LightClientFinalityUpdate_encode / _serialize do not call LightClientFinalityUpdate_size (writer cursor sizes the buffer); no other caller in types/ or src/',
    'r10-l02-kzg-decode/09': 'public: LightClientUpdate_decode(bytes) with the second offset below the first; the valid-only corpus cannot reach the refusal path; not shown by a targeted case this round',
    'r10-r01-reader-advance/11': 'public: BeaconState_decode(bytes) reads one field at the previous field offset; BeaconState has no corpus case under the size cap',
    'r10-w01-fixed-order/03': 'public: BeaconState_serialize(BeaconState_default() with genesis_time set) writes genesis_time and genesis_validators_root at swapped positions; BeaconState has no corpus case under the size cap',
    'r10-w02-var-slot/05': 'public: BeaconState_serialize writes two variable-field offsets into swapped slots; BeaconState has no corpus case under the size cap',
    'r10-d01-default/10': 'public: BeaconState_default() holds bv4_default() as justification_bits; BeaconState_serialize(BeaconState_default()) would write 0x01; the facade check overflowed the stack (unjudged); not in the probe (BeaconState default is too large for the probe build)',
}
rows, cnt = [], collections.Counter()
fam = collections.defaultdict(collections.Counter)
for fid, r in sorted(final.items()):
    f = fid.split('/')[0]
    fam[f][r['A']] += 1
    cnt[r['A']] += 1
    if r['A'] == 'KILLED':
        continue
    h = hdr(fid)
    roots = [(c['root'], c['verdict'], c['secs']) for c in r['checks']]
    row = {'id': fid, 'patch': 'tools/mutation_testing/manual_spec_mutants/patches/%s.patch' % fid, 'type': h.get('type'),
           'file': h.get('file'), 'rule': h.get('spec'), 'fault': h.get('fault'), 'proofs_A': r['A'], 'roots_checked': roots}
    if f == 'r10-d01-default':
        n = fid.split('/')[1]
        call, kind = DEF_CALLS.get(n, ('', ''))
        pr = probe.get(fid, {})
        row['counterexample'] = '%s: the spec default is all zero bytes (Default values; API_CONTRACTS X_default: serialize(default()) is the spec zero encoding); the mutant serializes a non-zero byte / bit and hashes to a different root' % call
        row['reachability'] = 'public: X_default() is the documented constructor of the object API (docs/API_CONTRACTS.md, types/runtime_index.json); every container default of a type holding %s goes through it (X_default -> <field>_default); no setter is needed' % kind
        if r['A'] == 'UNJUDGED':
            row['verdict'] = 'unjudged'
        else:
            row['verdict'] = 'critical'
        row['evidence'] = {'probe_p10a': pr, 'probe_case': PROBE_CASE.get(n), 'corpus': corpus.get(fid, {}).get('B', 'not run: the corpus decodes valid bytes, re-encodes and hashes them; it never calls X_default, so it cannot observe a default fault')}
    else:
        row['verdict'] = 'unjudged'
        row['proofs_A'] = 'UNJUDGED' if r['A'] in ('UNJUDGED', 'ERROR') else r['A']
        c = corpus.get(fid)
        row['counterexample'] = 'corpus: %s' % (('%s (%s disagreeing corpus cases)' % (c.get('B'), c.get('corpus_bad'))) if c else 'not run')
        row['reachability'] = 'public decode / serialize entry point of the type (X_decode / X_serialize); see the round-10 report'
        row['reachability'] = NOTE.get(fid, row['reachability'])
        row['evidence'] = {'corpus': c}
    rows.append(row)
json.dump(rows, open(dst, 'w'), indent=1)
print('final', dict(cnt), 'faults', len(final))
for f, c in sorted(fam.items()):
    print(f, dict(c))
