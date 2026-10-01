"""codegen/core/names.py: one readable name per type, distinct (the check `names.py --check` runs)."""
import unittest

from codegen.core import names


class NamesTest(unittest.TestCase):
    def test_mapping_is_nonempty_and_fork_prefixed(self):
        m = names.mapping()
        self.assertGreater(len(m), 200)
        self.assertIn('FuluBeaconState', set(m.values()))

    def test_readable_names_are_distinct_except_shared_basics(self):
        names.check()   # raises SystemExit on a collision


if __name__ == '__main__':
    unittest.main()
