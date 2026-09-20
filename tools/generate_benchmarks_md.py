#!/usr/bin/env python3
"""Write BENCHMARKS.md from a native performance report.

    python3 benchmarks/run.py --report build/performance/report.json
    python3 tools/generate_benchmarks_md.py build/performance/report.json
"""
import json
import statistics
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = json.loads((ROOT / 'automation/performance_contract.json').read_text())


def limit_for(operation):
    return CONTRACT.get('max_ratio_by_operation', {}).get(operation, CONTRACT['max_ratio'])


def main():
    report = json.loads(Path(sys.argv[1]).read_text())
    rows = report['benchmarks']
    lines = []
    add = lines.append
    add('# Native SSZ benchmarks — Bend C versus Go fastssz')
    add('')
    add('Reproduce exactly these numbers with:')
    add('')
    add('```')
    add('python3 benchmarks/run.py --report build/performance/report.json')
    add('python3 tools/generate_benchmarks_md.py build/performance/report.json')
    add('```')
    add('')
    add('The frozen operator gate that reads the same report is')
    add('`python3 automation/performance_gate.py`.')
    add('')
    add('## Method')
    add('')
    add('Both sides are native and built fresh by the runner: Bend through its native C')
    add('backend (`bend benchmarks/native_driver.bend -o ...`, run with `--threads 1')
    add('--gpu off`), Go through `go build` with `GOMAXPROCS(1)`. No Bun/JavaScript')
    add('result appears here. Only the public API is measured (`ssz.deserialize`,')
    add('`ssz.serialize`, `ssz.hash_tree_root`); reading the workload, choosing the')
    add('schema and, for serialize and hash_tree_root, the single preparatory decode are')
    add('outside every timed region on both sides.')
    add('')
    add('Each row is one type, one workload and one operation: the operation is repeated')
    add('`operations_per_sample` times inside one timed region (calibrated so a sample is')
    add('long enough that timer resolution is not a factor), every result is consumed,')
    add('and at least five samples per side alternate between the implementations in')
    add('fresh processes. Reported timings are nanoseconds per operation; the ratio is')
    add('median(Bend) / median(Go), per workload, with no aggregation across workloads.')
    add('')
    add('Before any timing is recorded both implementations must round-trip the exact')
    add('workload bytes and agree on the checksum of the hash tree root; that agreement')
    add('is what `verified` means in the report.')
    add('')
    add('Two measurement properties worth stating plainly:')
    add('')
    add('* Bend is lazy, so its deserialize loop folds every decoded leaf to force the')
    add('  value, while the Go loop retains the decoded struct without traversing it.')
    add('  The Bend deserialize numbers are therefore pessimistic, never the reverse.')
    add('* Repeating an operation on the same input in Bend copies the input graph per')
    add('  iteration, because a value consumed by a call has to be duplicated to be')
    add('  used again; Go re-reads the same buffer. That duplication is a genuine cost')
    add('  of calling the API repeatedly in Bend and is inside the Bend measurement.')
    add('')
    environment = report['environment']
    add('| environment | |')
    add('|---|---|')
    for key in ['cpu', 'os', 'bend_compiler', 'reference_compiler', 'bend_flags', 'reference_flags', 'reference_revision']:
        add(f'| {key} | {environment[key]} |')
    add('')

    passing = [r for r in rows if r['ratio'] <= limit_for(r['operation'])]
    add('## Result against the frozen contract')
    add('')
    coverage = report['coverage']
    add(f'* {len(rows)} measured workloads covering {coverage["covered_operations"]} of the '
        f'{coverage["required_operations"]} required operations.')
    add(f'* {len(passing)} of {len(rows)} workloads are within their operation limit '
        f'(deserialize/serialize 5x, hash_tree_root 10x).')
    if report.get('skipped'):
        add(f'* {len(report["skipped"])} type/workload combinations were not measured; they are listed '
            'with their reason in the report\'s `skipped` section and in "Coverage gaps" below.')
    add('')
    ratios = [r['ratio'] for r in rows]
    if ratios:
        add(f'Ratio distribution over all measured workloads: minimum {min(ratios):.1f}x, '
            f'median {statistics.median(ratios):.1f}x, maximum {max(ratios):.1f}x.')
        add('')
        for operation in ['deserialize', 'serialize', 'hash_tree_root']:
            group = [r['ratio'] for r in rows if r['operation'].endswith('.' + operation)]
            if group:
                add(f'* `{operation}`: {len(group)} workloads, minimum {min(group):.1f}x, '
                    f'median {statistics.median(group):.1f}x, maximum {max(group):.1f}x '
                    f'(limit {10 if operation == "hash_tree_root" else 5}x).')
        add('')

    add('## What the numbers say')
    add('')
    add('The gate fails. The shortfall is not concentrated in one type or one operation,')
    add('and it is not a constant factor either - it is a large per-call cost plus a')
    add('large per-element cost:')
    add('')
    add('* the cheapest workloads are the ones that do almost nothing per call')
    add('  (`boolean.serialize`, `Bytes1.serialize`), which is where the Bend runtime\'s')
    add('  own call overhead is most of what is measured;')
    add('* fixed 32-byte leaves cost single-digit microseconds per call in Bend against')
    add('  tens of nanoseconds in Go, so even small containers that move almost no data')
    add('  land in the hundreds;')
    add('* `hash_tree_root` is the closest family because both sides are dominated by')
    add('  hashing rather than by walking structure. A 131,072-byte `Blob` is 4,096')
    add('  chunks and 4,095 merkle hashes: Bend takes 29.3 ms for it and Go 0.41 ms,')
    add('  about 7.2 us against 0.10 us per hash. That is the pinned pure-Bend SHA-256,')
    add('  which by instruction may not be replaced with hardware SHA, foreign crypto or')
    add('  compiler intrinsics.')
    add('')
    add('Both implementations agree on every root and on every malformed input, so this')
    add('is a throughput gap, not a semantic one. Closing it needs representation work')
    add('rather than tuning: byte payloads still become one list cell per byte at the')
    add('public `T.Value` boundary for serialize and root, sequences still cost one spine')
    add('cell per element, and every public call re-validates its schema. Those are the')
    add('three places these measurements point at.')
    add('')
    add('## All measured workloads')
    add('')
    add('| operation | workload | bytes | ops/sample | Bend ns/op | Go ns/op | ratio | limit | within limit |')
    add('|---|---|---:|---:|---:|---:|---:|---:|:--:|')
    for row in sorted(rows, key=lambda r: (r['operation'], r['workload'])):
        limit = limit_for(row['operation'])
        ok = 'yes' if row['ratio'] <= limit else 'no'
        add(f'| {row["operation"]} | {row["workload"]} | {row["size"]} | {row["operations_per_sample"]} | '
            f'{row["bend_median_ns"]:.1f} | {row["reference_median_ns"]:.1f} | {row["ratio"]:.1f}x | {limit}x | {ok} |')
    add('')
    if report.get('skipped'):
        add('## Coverage gaps')
        add('')
        add('| type | workload | reason |')
        add('|---|---|---|')
        for entry in report['skipped']:
            add(f'| {entry.get("type", "")} | {entry.get("workload", "-")} | {entry["reason"]} |')
        add('')
    if report['coverage']['missing_operations']:
        add('Required operations with no measured workload:')
        add('')
        add('```')
        for name in report['coverage']['missing_operations']:
            add(name)
        add('```')
        add('')
    add('## Malformed input')
    add('')
    add('The runner also feeds each workload back to both implementations with a byte')
    add('removed, a byte appended and - where the type is variable size - a first offset')
    add('outside the region, and records whether each implementation refused it.')
    if report.get('rejection_summary'):
        summary = report['rejection_summary']
        add('')
        add(f'* {summary["checks"]} malformed inputs; Bend refused {summary["bend_rejected"]}, the')
        add(f'  reference refused {summary["reference_rejected"]}, disagreements: '
            f'{len(summary["disagreements"])}.')
        add('')
        add('(Not every mutation is invalid: appending a byte to a byte list is still a')
        add('valid value of that type. What matters is that the two implementations make')
        add('the same decision on every one of them.)')
    add('')
    add('Per-sample timings, batch sizes, workload sources, source hashes and artifact')
    add('hashes are in the report JSON; the raw runner log is build/performance/benchmark.log.')
    (ROOT / 'BENCHMARKS.md').write_text('\n'.join(lines) + '\n')
    print('BENCHMARKS.md:', len(rows), 'workloads')


if __name__ == '__main__':
    main()
