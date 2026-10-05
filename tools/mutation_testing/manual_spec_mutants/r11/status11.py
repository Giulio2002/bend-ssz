#!/usr/bin/env python3
"""Write the round 11 / 12 fix status into the survivors json files (agent/r11-fixes).

    python3 tools/mutation_testing/manual_spec_mutants/r11/status11.py

Reads r11/results/replay_fix11.json (replay_fix11.py) and sets, on every row of r11/manual_round_11_survivors.json and
r12/manual_round_12_survivors.json the fixes touched: `fix_status` (closed / removed / equivalent / documented), `fix_law` and `fix_location` (the
killing law, for a replayed fault), `fix_note`.
"""
import json
import os

R = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
REPLAY = os.path.join(R, 'tools/mutation_testing/manual_spec_mutants/r11/results/replay_fix11.json')
DEAD_B03 = {'02', '03', '05', '06', '07', '08'}


def key(fid):
    """r11-d02/03 -> (r11, d02, 03)"""
    rnd, rest = fid.split('-', 1)
    fam, n = rest.split('/')
    return rnd, fam, n


def main():
    rep = {}
    for r in json.load(open(REPLAY)):
        rnd, fam, n = key(r['id'])
        k = next((x for x in r['laws'] if x['status'] == 'KILLED'), None)
        rep[(rnd, fam, n)] = (r['verdict'], k)
    for rnd in ('11', '12'):
        path = os.path.join(R, f'tools/mutation_testing/manual_spec_mutants/r{rnd}/manual_round_{rnd}_survivors.json')
        rows = json.load(open(path))
        for row in rows:
            fam_full, n = row['id'].split('/')
            fam = fam_full.split('-')[1]
            hit = rep.get((f'r{rnd}', fam, n))
            if hit and hit[0] == 'KILLED':
                row['fix_status'] = 'closed'
                row['fix_law'] = hit[1]['law']
                row['fix_location'] = hit[1]['location']
                row['fix_note'] = f'replayed on agent/r11-fixes: killed in {hit[1]["secs"]} s'
            elif rnd == '11' and fam == 'b01':
                row['fix_status'] = 'removed'
                row['fix_note'] = 'dead code: the window validator X_ok (and X_ok_len) of a fixed-size kind no decoder or union option takes is no longer emitted (typed_object_runtime WINDOW_OK)'
            elif rnd == '11' and fam == 'b03' and n in DEAD_B03:
                row['fix_status'] = 'removed'
                row['fix_note'] = 'dead code: the window validator X_bx_ok of a box of a fixed-size value is no longer emitted (parents call X_bx_ok_at)'
            elif rnd == '11' and fam == 'b03' and n == '09':
                row['fix_status'] = 'documented'
                row['fix_note'] = ('unreachable in practice: the only invalid element of the transactions list is a byte list over 2^30 bytes (a 1 GiB input); '
                                   'its root or literal unfolds 2^25 chunks in the checker, so no law states it; the list validator calls bl1073741824_bx_ok '
                                   'by the same generated template the bad_box laws pin for every other boxed kind')
            elif rnd == '12' and fam == 'c02' and hit and hit[0] == 'SURVIVED':
                row['fix_status'] = 'equivalent'
                row['fix_note'] = ('X_putk is defined as X_putn for this kind (the validity is carried by the field writers): the mutant is the same '
                                   'function; X_serialize_vwriter_checked states the checked writer for every kind where the two differ')
        json.dump(rows, open(path, 'w'), indent=1)


if __name__ == '__main__':
    main()
