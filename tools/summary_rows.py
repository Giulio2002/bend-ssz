#!/usr/bin/env python3
"""tools/summary_rows.py: atomic result rows for tools/check_fast.sh.

    summary_rows.py write DIR UMBRELLA EXIT OK SECONDS MB CACHE_KEY HOW
    summary_rows.py collect DIR

Every umbrella writes its result row to DIR/rows/<umbrella>.row: the roots column comes from DIR/umb/plan.tsv (it can be
tens of kilobytes: too long for one append, which POSIX makes atomic only up to PIPE_BUF, so rows of umbrellas finishing at
the same time interleaved in a shared summary.tsv), written to a temporary file in the same directory and renamed into place
(rename is atomic). `collect` concatenates the rows, in plan order, into DIR/summary.tsv, the file that tools/check_stamp.py
and tools/check_fast.sh read (umbrella, exit, ok, seconds, peak MB, roots, cache key, how), and exits 1 with a message that
names the file for a row that does not have 6 to 8 tab-separated fields, a number that is not one, or two rows of one umbrella.
"""
import os
import sys
import tempfile


def row_text(d, u, rc, ok, s, mb, ck, how):
    roots = ''
    for line in open(os.path.join(d, 'umb', 'plan.tsv')):
        f = line.rstrip('\n').split('\t')
        if f[0] == u:
            roots = f[3] if len(f) > 3 else ''
    return '\t'.join([u, str(rc), str(ok), str(s), str(mb), roots, ck, how]) + '\n'


def write_row(d, u, text):
    rows = os.path.join(d, 'rows')
    os.makedirs(rows, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix='.' + u + '.', dir=rows)
    with os.fdopen(fd, 'w') as h:
        h.write(text)
    os.rename(tmp, os.path.join(rows, u[:-5] + '.row' if u.endswith('.bend') else u + '.row'))


def parse(text, where):
    """the 8 fields of a row, or ValueError naming `where`"""
    if not text.endswith('\n') or text.count('\n') != 1:
        raise ValueError(f'{where}: not exactly one line')
    f = text.rstrip('\n').split('\t')
    if not 6 <= len(f) <= 8:
        raise ValueError(f'{where}: {len(f)} fields, expected 6 to 8 (umbrella, exit, ok, seconds, peak MB, roots, key, how)')
    try:
        int(f[1]), int(f[2]), float(f[3]), int(f[4])
    except ValueError:
        raise ValueError(f'{where}: exit/ok/seconds/peak MB are not numbers: {f[1:5]}')
    return f


def collect(d):
    plan = [l.split('\t')[0] for l in open(os.path.join(d, 'umb', 'plan.tsv')) if l.strip()]
    rows = os.path.join(d, 'rows')
    out, bad, seen = [], [], set()
    for fn in sorted(os.listdir(rows)) if os.path.isdir(rows) else []:
        if fn.startswith('.') or not fn.endswith('.row'):
            continue
        p = os.path.join(rows, fn)
        try:
            f = parse(open(p).read(), p)
        except ValueError as e:
            bad.append(str(e))
            continue
        if f[0] in seen:
            bad.append(f'{p}: a second row for {f[0]}')
        seen.add(f[0])
        out.append('\t'.join(f) + '\n')
    order = {u: i for i, u in enumerate(plan)}
    out.sort(key=lambda t: order.get(t.split('\t')[0], len(order)))
    open(os.path.join(d, 'summary.tsv'), 'w').writelines(out)
    for b in bad:
        print('summary_rows: BAD ROW ' + b, file=sys.stderr)
    return 1 if bad else 0


def main():
    if len(sys.argv) >= 3 and sys.argv[1] == 'collect':
        sys.exit(collect(sys.argv[2]))
    if len(sys.argv) == 10 and sys.argv[1] == 'write':
        _, _, d, u, rc, ok, s, mb, ck, how = sys.argv
        write_row(d, u, row_text(d, u, rc, ok, s, mb, ck, how))
        return
    sys.exit(__doc__)


if __name__ == '__main__':
    main()
