#!/usr/bin/env python3
"""The tables of docs/DECODE_AMPLIFICATION.md from measurements (tools/decode_amp/measure.py) and the cost table (codegen/decode_cost.json).

    python3 tools/decode_amp/report.py MEASURE.json > table.md
"""
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]


def dcost(size, k):
    if k == 0:
        return 524288
    w = (size >> 3) + 1
    return w * k + 524288 if w <= 4294443007 // k else 4294967295


def worst(rows):
    """the row with the largest density (ratio for inputs of at least 128 KiB, else the largest input)"""
    big = [r for r in rows if 'ratio' in r and r['bytes'] >= (128 << 10)]
    if big:
        return max(big, key=lambda r: r['ratio']), True
    rs = [r for r in rows if 'bytes' in r]
    return (max(rs, key=lambda r: r['bytes']) if rs else None), False


def main():
    meas = json.load(open(sys.argv[1]))
    cost = json.loads((ROOT / 'codegen/decode_cost.json').read_text())['k']
    print('| name | worst shape | input bytes | peak RSS KiB | refused KiB | ratio | slope | K | bound / decoded |')
    print('|---|---|---:|---:|---:|---:|---:|---:|---:|')
    over, rows = 0, []
    for n in meas:
        rb, big = worst(meas[n]['rows'])
        rows.append((-(rb['ratio'] if rb and big else -1), n, rb, big))
        for r in meas[n]['rows']:
            if r.get('peak_kb') and r.get('refused_peak_kb') and (r['peak_kb'] - r['refused_peak_kb']) * 1024 > dcost(r['bytes'], cost[n]['k']) * 8:
                over += 1
    for _, n, rb, big in sorted(rows, key=lambda x: (x[0], x[1])):
        k = cost[n]['k']
        if rb is None:
            print(f'| {n} | - | - | - | - | - | - | {k} | - |')
            continue
        dec = max(1, (rb['peak_kb'] - (rb['refused_peak_kb'] or rb['peak_kb'])) * 1024)
        slope = rb['slope'] if big and 'slope' in rb and rb['bytes'] - rb.get('small_bytes', rb['bytes']) >= (1 << 20) else '-'
        print(f"| {n} | `{rb['path']}` | {rb['bytes']:,} | {rb['peak_kb']:,} | {rb['refused_peak_kb'] or '-'} | {rb['ratio'] if big and 'ratio' in rb else 'small'} | {slope} | {k} | "
              f"{dcost(rb['bytes'], k) * 8 / dec:.1f} |")
    print()
    print(f'Measured shapes in all: {sum(len(v["rows"]) for v in meas.values())}; above their bound: {over}.')


if __name__ == '__main__':
    main()
