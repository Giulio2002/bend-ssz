"""tools/summary_rows.py: result rows of umbrellas finishing together never interleave (rows of tens of kilobytes)."""
import multiprocessing
import os
import sys
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import summary_rows as SR  # noqa: E402

N = 24


def work(args):
    d, i = args
    SR.write_row(d, f'{i:03d}.bend', SR.row_text(d, f'{i:03d}.bend', 0, 1, 12.5 + i, 4000 + i, '-', 'run'))


class SummaryRows(unittest.TestCase):
    def setUp(self):
        self.d = tempfile.mkdtemp()
        os.makedirs(os.path.join(self.d, 'umb'))
        with open(os.path.join(self.d, 'umb', 'plan.tsv'), 'w') as h:
            for i in range(N):
                roots = ' '.join(f'proofs/gate/slop/group{i}/name_{j}_generated.bend' for j in range(1200 + i))   # ~70 KB: far over PIPE_BUF
                h.write(f'{i:03d}.bend\t100.0\t5\t{roots}\n')

    def test_concurrent_writers_collect_to_parseable_rows(self):
        with multiprocessing.Pool(12) as p:
            p.map(work, [(self.d, i) for i in range(N)])
        self.assertEqual(SR.collect(self.d), 0)
        lines = open(os.path.join(self.d, 'summary.tsv')).read().split('\n')[:-1]
        self.assertEqual(len(lines), N)
        for i, line in enumerate(lines):
            f = line.split('\t')
            self.assertEqual(len(f), 8)
            self.assertEqual(f[0], f'{i:03d}.bend')
            self.assertEqual(len(f[5].split()), 1200 + i)

    def test_a_broken_row_is_reported_not_a_traceback(self):
        os.makedirs(os.path.join(self.d, 'rows'))
        open(os.path.join(self.d, 'rows', '000.row'), 'w').write('oof_generated.bend proofs/api/x\n')
        self.assertEqual(SR.collect(self.d), 1)


if __name__ == '__main__':
    unittest.main()
