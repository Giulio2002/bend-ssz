"""codegen/core/bend_source_text_helpers.py: the text builders the generators share."""
import unittest

from codegen.core import bend_source_text_helpers as B


class BendTextTest(unittest.TestCase):
    def test_nat_sum(self):
        self.assertEqual(B._sz(['b', 'c'], 'a'), 'Nat.add(Nat.add(a, b), c)')
        self.assertEqual(B._sz([], 'a'), 'a')

    def test_logs(self):
        self.assertEqual([B.ceil_log2(x) for x in (1, 2, 3, 4, 5, 1024, 1025)], [0, 1, 2, 2, 3, 10, 11])
        self.assertEqual([B.log2c(x) for x in (1, 2, 3, 4, 5, 1024, 1025)], [0, 1, 2, 2, 3, 10, 11])
        self.assertEqual(B.log2c(0), 0)

    def test_cons_and_fold(self):
        self.assertEqual(B.cons(['a', 'b'], 'Nil{}'), 'Con{a, Con{b, Nil{}}}')
        self.assertEqual(B.fold_and([]), 'True{}')
        self.assertEqual(B.fold_and(['p']), 'p')
        self.assertEqual(B.fold_and(['p', 'q', 'r']), 'Bool.and(p, Bool.and(q, r))')

    def test_words(self):
        self.assertEqual(B.wl(['a', 'b']), '[a, b]')
        self.assertEqual(B.wpat([0, 1]), 'WCon{0, WCon{1, WNil{}}}')
        self.assertEqual(B.wp([1]), 'U32{WCon{1, WNil{}}}')
        self.assertEqual(B.pos(0), 'x')
        self.assertEqual(B.pos(3), '3n+x')

    def test_text_edits(self):
        self.assertEqual(B.T_('aab', {'a': 'x', 'aa': 'y'}), 'yb')
        self.assertEqual(B.cut('one-two-three', '-two', '-three'), 'one-three')

    def test_wsplit_orders_literal_sums_small_first(self):
        self.assertEqual(B.wsplit(2, 5, 7), ('Nat.add(2n, 5n)', 'Nat.add(2n, 7n)', 'VBE.win_splitK'))
        self.assertEqual(B.wsplit(5, 2, 1), ('Nat.add(2n, 5n)', 'Nat.add(1n, 5n)', 'VBE.win_splitR'))


if __name__ == '__main__':
    unittest.main()
