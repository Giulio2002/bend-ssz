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
CONTRACT = json.loads((ROOT / 'benchmarks/performance_contract.json').read_text())


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
    add('## Method')
    add('')
    add('Both sides are native and built fresh by the runner, one sequential thread each.')
    add('Bend is the **generated typed owning object API** through its native C')
    add('backend, run with `--threads 1 --gpu off`; the measured programs are')
    add('`benchmarks/objprog/g<k>.bend` over `types/<Name>_*_generated.bend`, which')
    add('`codegen/impl/typed_object_runtime.py` emits from `codegen/fulu.yaml` (see docs/LAYOUT.md).')
    add('Each is built under a compile-memory cap, every attempt recorded in the')
    add('report\'s `bend_compiles`. Go is pinned fastssz via go-eth2-client, built')
    add('with `go build` and run with `GOMAXPROCS(1)`. No Bun/JavaScript result')
    add('appears here.')
    add('')
    add('What each operation is:')
    add('')
    add('| operation | Bend (generated object API) | Go fastssz |')
    add('|---|---|---|')
    add('| deserialize | `X_decode(buf, size)`: the generated validator over the whole window, then the generated reader, which builds the typed owning object and copies its storage out of the input; plus a fold over every field of the result, so no construction is left unevaluated | `UnmarshalSSZ` into the generated struct |')
    add('| serialize | `X_serialize(o)`: the checked encoder (refuses an invalid object, else fresh canonical bytes), after one untimed decode; every encoding is consumed | `MarshalSSZ` after one untimed decode |')
    add('| hash_tree_root | `X_hash_tree_root(h, o)` of that object, with one hasher created before the clock starts, as fastssz reuses its package-level zero-hash table | `HashTreeRoot` after one untimed decode |')
    add('')
    add('Reading the workload into a buffer and selecting the type are outside every')
    add('timed region on both sides. Each row is one type, one workload and one')
    add('operation. Each side calibrates its own repetition count toward a 0.25 s')
    add('sample (capped at five million operations) and repeats the operation that')
    add('many times inside one timed region, consuming every result. Timings are')
    add('normalised by that side\'s own count: `operations_per_sample` is the Bend')
    add('count and `reference_operations_per_sample` the Go count, both in the report.')
    add('At least five samples per side alternate between the implementations in fresh')
    add('processes. The ratio is median(Bend ns/op) / median(Go ns/op) per workload, with')
    add('no aggregation across workloads. Capped batches of very fast operations (a few')
    add('nanoseconds) are the ones most exposed to timer resolution.')
    add('')
    add('Before any timing, both implementations must round-trip the exact workload')
    add('bytes (Bend: decode, then `X_serialize` compared byte for byte) and agree on the')
    add('checksum of the hash tree root, and on official fixtures that checksum must')
    add('equal the official root\'s. That agreement is what `verified` means.')
    add('')
    add('Stated plainly:')
    add('')
    add('* Both sides start from bytes and end with a fully constructed typed value,')
    add('  and both allocate and copy to do it. The decode row includes a fold over')
    add('  every field of the Bend object, because record fields are lazy and a')
    add('  decode that left them unevaluated would not be comparable.')
    add('* Go\'s SHA-256 uses the CPU\'s SHA instructions. Bend uses the pinned')
    add('  pure-Bend package, which by instruction may not be replaced with hardware')
    add('  SHA, foreign crypto or intrinsics. On the Apple M4 host of iteration 22 a')
    add('  64-byte node cost about 0.26 us against Go\'s ~0.06 us, so `hash_tree_root`')
    add('  starts about 4x behind before any walking overhead (not re-measured on the')
    add('  host of this report). Whether every row meets its 10x limit is stated')
    add('  below from this report\'s own numbers.')
    add('* Encode allocates its output with `Array.new(U32, d, 0)`, the only')
    add('  allocation the pinned Base offers, which zero-fills a power-of-two number')
    add('  of words (measured 0.24 ns/word on the iteration-22 Apple M4 host, against')
    add('  0.19 ns/word for the copy itself). Go\'s `make`/`append` does not pay that. For a flat value such as')
    add('  `Blob` the zero-fill alone costs about as much as Go\'s whole marshal. This')
    add('  is a property of the available primitives and is reported, not worked')
    add('  around.')
    add('* The machine was not idle: other user processes ran throughout (on the')
    add('  Linux host a load average near 100 on 48 CPUs). Samples alternate between')
    add('  the two sides, so the load affects both, but it widens the sample spread.')
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
    failing = [r for r in rows if r['ratio'] > limit_for(r['operation'])]
    if not failing:
        add('Every measured workload is within its limit.')
    else:
        add(f'{len(failing)} workloads exceed their limit. By operation:')
        add('')
        for operation in ['deserialize', 'serialize', 'hash_tree_root']:
            group = sorted([r for r in failing if r['operation'].endswith('.' + operation)],
                           key=lambda r: -r['ratio'])
            if not group:
                add(f'* `{operation}`: none over the limit.')
                continue
            worst = ', '.join(f'{r["operation"].rsplit(".", 1)[0]} {r["workload"]} {r["ratio"]:.1f}x'
                              for r in group[:6])
            add(f'* `{operation}`: {len(group)} over the limit; worst: {worst}.')
    closest = sorted(rows, key=lambda r: -r['ratio'] / limit_for(r['operation']))[:5]
    add('')
    add('Closest to their limits (median ratio / limit), the rows to re-measure first when')
    add('the host changes:')
    add('')
    for r in closest:
        add(f"* `{r['operation']}` {r['workload']}: {r['ratio']:.1f}x of {limit_for(r['operation'])}x")
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
