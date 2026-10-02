#!/usr/bin/env python3
"""Every coverage figure the documentation states, computed from the artifacts.

    python3 codegen/docs/documentation_figures.py [--check]

The docs (DOCS below) mark each figure as <!-- fig:KEY -->text<!-- /fig -->; this script
recomputes every marked text from the generated artifacts and rewrites it (--check: fails,
naming the file and key, when a doc differs, or a key is unknown). Sources:

  proofs/gate/api_map.json   the object API's laws per name (codegen/proofs/facades/object_api_coverage_gate.py)
  proofs/gate/MISSING.txt    the core (name, law) pairs with no proving law (codegen/proofs/facades/object_api_coverage_gate.py)
  e2e/manifest.json          the bridges, their premises and input bounds (codegen/proofs/bridges/object_api_model_bridges.py)
  proofs/api/                the facades (codegen/proofs/facades/object_api_facade_proofs.py)
  e2e/COMPOSED.txt           the composed decode;encode / decode;root theorems (codegen/proofs/composed/decode_then_encode_theorems.py)
  codegen/docs/end_to_end_statement_list.py      the statement files: the object-mutation laws (proofs/obj/coll_api_*,
                             prep_setters.bend) and the setter laws
                             (e2e/*_e2e_set_generated.bend, codegen/proofs/collections/setter_bridge_compositions.py)
  benchmarks/evidence/check_fast.json   the recorded full check (tools/check_fast.sh): its size and timings,
                             so a new stamp makes this check fail until the docs are regenerated

So a doc cannot claim more coverage than the artifacts show: a regenerated artifact with other
figures makes this check (part of regenerate_all --check) fail until the docs are regenerated.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[2]))  # the repository root: `codegen` is importable when this file runs as a script
import json
import re
import sys

from codegen.core.repository_paths import ROOT  # noqa: E402
DOCS = ['README.md', 'docs/RESULTS.md', 'docs/PREMISES.md', 'docs/BUILD.md', 'docs/TRUST.md']
FIG = re.compile(r'<!-- fig:([a-z0-9_]+) -->(.*?)<!-- /fig -->', re.S)
BRIDGE = {'e2e_encode': 'i', 'e2e_decode_accept': 'ii', 'e2e_decode_view': 'ii',
          'e2e_decode_reject': 'iii', 'e2e_root': 'iv'}
POW = {2 ** 32 - 32: 'NMAX = 2^32 - 32', 2 ** 30: '2^30', 2 ** 29: '2^29'}


def _params(sig):
    """the binder names of a def signature's parameters (top level only)"""
    s = sig.replace('->', '=>')
    i = s.index('(') + 1
    depth, cur, out = 0, '', []
    for ch in s[i:]:
        if ch in '({[<':
            depth += 1
        if ch in ')}]>':
            if depth == 0:
                out.append(cur)
                break
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur)
            cur = ''
            continue
        cur += ch
    return [re.match(r'\s*[+-]?(\w+)', p).group(1) for p in out if p.strip()]


def premise_rows():
    """per bridged name, the hypotheses of its (i), (ii) and (iv) statements beyond the object / input
    (e2e/STATEMENTS.txt)"""
    t = (ROOT / 'e2e/STATEMENTS.txt').read_text()
    rows = {}
    for m in re.finditer(r'^def (\w+)_e2e_(encode|decode_view|decode_accept|root)\(.*?(?=\n(?:def |## |import |$))', t, re.M | re.S):
        rows.setdefault(m.group(1), {})[m.group(2)] = _params(m.group(0))
    out = {}
    for n, r in sorted(rows.items()):
        e = [p for p in r.get('encode', []) if p not in ('o', 'rep')]
        d = [p for p in (r.get('decode_view') or r.get('decode_accept') or []) if p not in ('bs', 'n', 'hn', 'hd', 'o')]
        ro = [p for p in r.get('root', []) if p not in ('h', 'o', 'rep')]
        out[n] = (e, d, ro)
    return out


def names_list(ns):
    return ', '.join(ns) if ns else 'none'


def figures():
    amap = json.loads((ROOT / 'proofs/gate/api_map.json').read_text())
    man = json.loads((ROOT / 'e2e/manifest.json').read_text())
    miss = [l for l in (ROOT / 'proofs/gate/MISSING.txt').read_text().splitlines()
            if l.strip() and not l.startswith('#')]
    fulu, gen, core, laws, mp = amap['fulu'], amap['generic'], amap['core_laws'], amap['laws'], amap['map']
    names = fulu + gen
    f = {}
    f['names'] = str(len(names))
    f['fulu'] = str(len(fulu))
    f['generic'] = str(len(gen))
    f['core_pairs'] = str(len(names) * len(core))
    f['missing'] = str(len(miss))
    f['facade_files'] = str(len(list((ROOT / 'proofs/api').glob('*_proof_generated.bend'))))
    f['core_laws'] = ', '.join('`%s`' % k for k in core)
    extra = [k for k in laws if k not in core]
    rows = ['| Law | Names |', '|---|---|']
    for k in core:
        rows.append('| `%s` | %d |' % (k, sum(1 for n in names if mp[n].get(k))))
    for k in extra:
        rows.append('| `%s` | %d |' % (k, sum(1 for n in names if mp[n].get(k))))
    f['law_table'] = '\n' + '\n'.join(rows) + '\n'

    got = {}
    for es in man['files'].values():
        for e in es:
            for l in e['laws']:
                s = l[len(e['name']) + 1:]
                if s in BRIDGE:
                    got.setdefault(e['generated_name'], set()).add(BRIDGE[s])
    full = [n for n in names if got.get(n, set()) >= {'i', 'ii', 'iii', 'iv'}]
    f['bridged_full'] = str(len(full))
    f['bridged_i'] = str(sum(1 for n in names if 'i' in got.get(n, ())))
    f['bridged_iv'] = str(sum(1 for n in names if 'iv' in got.get(n, ())))
    f['bridged_dec'] = str(sum(1 for n in names if {'ii', 'iii'} <= got.get(n, set())))
    nodec = [n for n in names if not {'ii', 'iii'} <= got.get(n, set())]
    f['no_dec_bridge'] = names_list(['`%s`' % n for n in nodec])
    f['no_dec_count'] = str(len(nodec))
    f['unbridged'] = names_list(['`%s`' % n for n in names if not got.get(n)])
    f['manifest_open'] = ', '.join('`%s` %s' % (k, 'empty' if not man[k] else '%d entries' % len(man[k]))
                                   for k in ('uncovered', 'decode_uncovered', 'root_awaiting'))
    ws = man['word_storage']
    f['word_storage'] = str(len(ws))
    f['word_storage_awaiting'] = names_list(['`%s`' % k for k, v in sorted(ws.items()) if v['awaiting']])

    ib = man['input_bounds']
    by = {}
    for n, v in sorted(ib.items()):
        by.setdefault(v['input_bound_bytes'], []).append(n)
    lines = []
    for b in sorted(by, reverse=True):
        lines.append('%s: %s' % (POW.get(b, str(b)), names_list(by[b]) if b != 2 ** 32 - 32 else '%d names' % len(by[b])))
    f['input_bounds'] = '; '.join(lines)
    short = [e['name'] for e in man['input_bound_short']]
    f['input_bound_short_count'] = str(len(short))
    f['input_bound_short'] = names_list(short)
    pr = premise_rows()
    rows = ['| Name | (i) encode | (ii)/(iii) decode | (iv) root |', '|---|---|---|---|']
    for n, (e, d, ro) in pr.items():
        if e or d or ro:
            rows.append('| %s | %s | %s | %s |' % (n, ', '.join('`%s`' % x for x in e) or '-', ', '.join('`%s`' % x for x in d) or '-',
                                                  ', '.join('`%s`' % x for x in ro) or '-'))
    f['premise_table'] = '\n' + '\n'.join(rows) + '\n'
    f['premise_free'] = str(sum(1 for e, d, ro in pr.values() if not (e or d or ro)))
    f['encode_premise_free'] = str(sum(1 for e, d, ro in pr.values() if not e))
    f['root_premise_free'] = str(sum(1 for e, d, ro in pr.values() if not ro))
    hv = man['decoded_premises']['hv_SDB']['names']
    f['hv_decoded_count'] = str(len(hv))
    f['hv_decoded'] = names_list(hv)
    wit = sorted(p.name[:-len('_e2e_witness_generated.bend')] for p in (ROOT / 'e2e').glob('*_e2e_witness_generated.bend'))
    f['witness_count'] = str(len(wit))
    wrows = [l.split('\t') for l in (ROOT / 'e2e/WITNESS.txt').read_text().splitlines() if l and not l.startswith('#')]
    f['witness_total'] = str(len(wrows))
    wpend = [r[0] for r in wrows if r[1] != 'witnessed']
    f['witness_pending'] = names_list(wpend) if wpend else 'none'
    f['witness_nonempty'] = str(sum(1 for n in wit if 'def NE()' in (ROOT / f'e2e/{n}_e2e_witness_generated.bend').read_text()))
    dwr = [l.split('\t') for l in (ROOT / 'e2e/DECODE_WITNESS.txt').read_text().splitlines() if l and not l.startswith('#')]
    f['dw_files'] = str(sum(1 for r in dwr if r[1] == 'witnessed'))
    f['dw_pending'] = str(sum(1 for r in dwr if r[1] != 'witnessed'))
    f['dw_pending_names'] = names_list([r[0] for r in dwr if r[1] != 'witnessed']) if any(r[1] != 'witnessed' for r in dwr) else 'none'
    capi = sorted((ROOT / 'e2e').glob('*_api_witness_generated.bend'))
    croot = sorted((ROOT / 'e2e').glob('*_api_root_witness_generated.bend'))
    cset = sorted((ROOT / 'e2e').glob('*_e2e_set_witness_generated.bend'))
    cdef = lambda q: len(re.findall(r'^def \w+_witness\(', q.read_text(), re.M))
    f['collw_files'] = str(len(capi) + len(croot))
    f['collw_api'] = str(sum(cdef(q) for q in capi))
    f['collw_root'] = str(sum(cdef(q) for q in croot))
    f['collw_total'] = str(sum(cdef(q) for q in capi + croot))
    f['collw_set'] = str(sum(cdef(q) for q in cset))
    f['collw_set_files'] = str(len(cset))
    f['collw_pending'] = str(sum(1 for l in (ROOT / 'e2e/COLL_WITNESS.txt').read_text().splitlines() if l.startswith('  pending')))
    serf = list((ROOT / 'e2e').glob('*_e2e_ser_generated.bend'))
    sert = [q.read_text() for q in serf]
    f['ser_files'] = str(len(serf))
    f['ser_decoded_hv'] = str(sum(1 for t in sert if '_e2e_decoded_hv(' in t))
    f['ser_total'] = str(sum(1 for t in sert if '_e2e_valid_total(' in t))
    f['ser_prem'] = str(sum(1 for t in sert if '_e2e_valid_of_prem(' in t))
    f['ser_domain'] = str(sum(1 for t in sert if '_e2e_serialize_domain(' in t))
    f['ser_count'] = str(sum(1 for q in serf if '_ser_l2(' not in q.read_text()))
    f['ser_lin_count'] = str(sum(1 for q in serf if '_ser_l2(' in q.read_text()))
    # the recorded full check (tools/check_fast.sh's stamp)
    st = json.loads((ROOT / 'benchmarks/evidence/check_fast.json').read_text())
    tot = st.get('totals', {})
    f['check_umbrellas'] = str(st.get('plan_umbrellas', len(st.get('umbrellas', []))))
    f['check_files'] = f"{st.get('files', 0):,}"
    f['check_cpu'] = f"{round(tot.get('cpu_seconds', 0)):,}"
    slow = tot.get('slowest_umbrella_seconds') or max([u.get('seconds') or 0 for u in st.get('umbrellas', [])] or [0])
    f['check_slowest'] = f'{round(slow)}'
    wall = tot.get('wall_seconds')
    f['check_wall'] = f'{wall / 60:.1f}' if wall else f'at least {slow / 60:.1f}'
    f['check_commit'] = st.get('commit', 'unknown')[:8]
    # the runtime evidence (benchmarks/evidence/*.json, tests_generated/ and benchmarks/checks/)
    ev = json.loads((ROOT / 'benchmarks/evidence/fuzz_objects.json').read_text())
    prov = ev['provenance']
    f['evidence_commit'] = prov['git_commit'][:8]
    f['evidence_date'] = prov['utc'][:10]
    c, fam = ev['counts'], ev['by_family']
    f['fuzz_types'] = str(ev['types'])
    f['fuzz_fulu'] = str(fam['fulu']['types'])
    f['fuzz_generic'] = str(fam['generic']['types'])
    f['fuzz_valid'] = f"{c['valid']:,}"
    f['fuzz_random'] = f"{c['invalid']:,}"
    f['fuzz_boundary'] = f"{c['boundary']:,}"
    f['fuzz_kinds'] = str(len(ev['mutation_kinds']))
    f['fuzz_history'] = f"{c['history']:,}"
    f['fuzz_setter_types'] = str(len(ev['types_with_setters']))
    f['fuzz_mismatches'] = str(ev['findings_total'])
    f['fuzz_elapsed'] = f"{ev['elapsed_s'] / 60:.0f}"
    rt = json.loads((ROOT / 'benchmarks/evidence/runtime_tests.json').read_text())
    f['rt_tests'] = str(rt['counts']['tests'])
    f['rt_assertions'] = f"{rt['counts']['assertions']:,}"
    f['composed'] = str(sum(1 for l in (ROOT / 'e2e/COMPOSED.txt').read_text().splitlines() if l.endswith('\tcomposed')))
    dr = sorted(p.name[:-len('_e2e_decrep_generated.bend')] for p in (ROOT / 'e2e').glob('*_e2e_decrep_generated.bend'))
    f['decrep_count'] = str(len(dr))
    f['decrep_names'] = names_list(['`%s`' % n for n in dr])
    f.update(object_law_figures())
    f.update(pending_figures())
    return f


def pending_figures():
    """the names without a composed theorem, each with the reason e2e/COMPOSED.txt gives (codegen/proofs/composed/decode_then_encode_theorems.py)"""
    rows = ['| Name | Why there is no composed theorem |', '|---|---|']
    for l in (ROOT / 'e2e/COMPOSED.txt').read_text().splitlines():
        if l.startswith('#') or not l.strip():
            continue
        n, st = l.split('\t', 1)
        if st != 'composed':
            rows.append('| `%s` | %s |' % (n, st.replace('pending: ', '', 1).replace('|', '\\|')))
    f = {'pending_count': str(len(rows) - 2), 'pending_table': '\n' + '\n'.join(rows) + '\n'}
    return f


def object_law_figures():
    """the object-mutation laws and their compositions with the bridges, as e2e/STATEMENTS.txt lists
    them (codegen/docs/end_to_end_statement_list.py statement_files())"""
    from codegen.docs import end_to_end_statement_list as ST
    sf = ST.statement_files()
    f = {}

    def stm(prefix):
        return sum(len(v) for k, v in sf.items() if k.startswith(prefix))

    def sections(glob, strip=r'(_obj)?_g\d+$'):
        names = set()
        for p in ROOT.glob(glob):
            for m in re.finditer(r'^# ---- (\w+) ----$', p.read_text(), re.M):
                names.add(re.sub(strip, '', m.group(1)))
        return len(names)
    coll = [l for k, v in sf.items() if k.startswith(('proofs/obj/coll_api_', 'proofs/obj/coll_seq', 'proofs/obj/coll_bits', 'proofs/obj/coll_bytes', 'proofs/obj/coll_root')) for l in v]
    f['obj_coll_statements'] = str(len(coll))
    f['obj_coll_count'] = str(sections('proofs/obj/coll_api_*.bend', r'$^'))
    f['obj_coll_readback'] = str(len({re.match(r'(\w+?)_api_', l).group(1) for l in coll if l.endswith('_api_read_set')}))
    f['obj_coll_root'] = str(len({re.match(r'(\w+?)_api_', l).group(1) for l in coll if l.endswith('_api_root_set')}))
    f['obj_coll_view'] = str(len({re.match(r'(\w+?)_api_', l).group(1) for l in coll if l.endswith('_api_view_set')}))
    f['obj_setter_laws'] = str(stm('proofs/obj/prep_setters'))
    f['obj_swap_laws'] = str(stm('proofs/obj/fields_'))
    f['obj_setter_containers'] = str(len({re.match(r'(\w+?)_set_', l).group(1)
                                          for k, v in sf.items() if k.startswith('proofs/obj/prep_setters') for l in v}))
    sets = [l for k, v in sf.items() if k.endswith('_e2e_set_generated.bend') for l in v]
    f['set_containers'] = str(sum(1 for k in sf if k.endswith('_e2e_set_generated.bend')))
    f['set_view_count'] = str(sum(1 for l in sets if l.endswith('_view')))
    f['set_root_count'] = str(sum(1 for l in sets if l.endswith('_root')))
    f['set_encode_count'] = str(sum(1 for l in sets if l.endswith('_encode')))
    f['set_checked_count'] = str(sum(1 for l in sets if l.endswith('_flag')))
    return f


def render(text, fig, path):
    bad = []

    def sub(m):
        if m.group(1) not in fig:
            bad.append(m.group(1))
            return m.group(0)
        return '<!-- fig:%s -->%s<!-- /fig -->' % (m.group(1), fig[m.group(1)])
    out = FIG.sub(sub, text)
    if bad:
        sys.exit('documentation_figures: %s: unknown figure %s' % (path, ', '.join(bad)))
    return out


def main():
    check = '--check' in sys.argv[1:]
    fig = figures()
    stale = []
    for d in DOCS:
        p = ROOT / d
        old = p.read_text()
        new = render(old, fig, d)
        if new != old:
            if check:
                keys = [a.group(1) for a, b in zip(FIG.finditer(old), FIG.finditer(new)) if a.group(2) != b.group(2)]
                stale.append('%s (%s)' % (d, ', '.join(keys)))
            else:
                p.write_text(new)
    if stale:
        print('documentation_figures: stale figures in ' + '; '.join(stale) + ' (run python3 codegen/docs/documentation_figures.py)')
        sys.exit(1)


if __name__ == '__main__':
    main()
