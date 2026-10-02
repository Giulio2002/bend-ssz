#!/usr/bin/env python3
"""Unit tests of tools/umbrella_cache.py: key stability and the not-cacheable rule.   python3 -m unittest tools.test_umbrella_cache"""
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import umbrella_cache as UC  # noqa: E402


class Tree(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        r = self.tmp.name
        self.old = (UC.ROOT, os.environ.get('BEND_LIB'), UC._MODULES.copy(), UC.CACHE_DIR)
        UC.ROOT = r
        os.environ['BEND_LIB'] = os.path.join(r, 'lib')
        UC.CACHE_DIR = os.path.join(r, 'cache')
        UC._MODULES.clear()
        self.w('a.bend', 'import Base\nimport ./sub/b.bend as B\n')
        self.w('sub/b.bend', 'import Base\nimport ../c.bend as C\nimport 0xabc/p.bend as P\n')
        self.w('c.bend', 'import Base\n')
        self.w('d.bend', 'import Base\nimport ./c.bend as C\n')
        self.w('lib/0xabc/p.bend', 'import Base\n')

    def tearDown(self):
        UC.ROOT, lib, mods, UC.CACHE_DIR = self.old
        UC._MODULES.clear()
        UC._MODULES.update(mods)
        if lib is None:
            os.environ.pop('BEND_LIB', None)
        else:
            os.environ['BEND_LIB'] = lib
        self.tmp.cleanup()

    def w(self, rel, text):
        p = os.path.join(self.tmp.name, rel)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, 'w') as f:
            f.write(text)
        UC._MODULES.clear()

    def key(self, roots, s=''):
        return UC.key(roots, s, ident='checker')

    def test_same_tree_same_key(self):
        self.assertEqual(self.key(['a.bend']), self.key(['a.bend']))
        self.assertEqual(self.key(['a.bend', 'd.bend']), self.key(['d.bend', 'a.bend']))

    def test_deep_change_changes_only_the_umbrellas_that_contain_it(self):
        ka, kd = self.key(['a.bend']), self.key(['d.bend'])
        self.w('c.bend', 'import Base\n# one byte\n')          # c is under a (through sub/b) and under d
        self.assertNotEqual(ka, self.key(['a.bend']))
        self.assertNotEqual(kd, self.key(['d.bend']))
        ka, kd = self.key(['a.bend']), self.key(['d.bend'])
        self.w('d.bend', 'import Base\nimport ./c.bend as C\n# only d\n')
        self.assertEqual(ka, self.key(['a.bend']))               # a does not contain d
        self.assertNotEqual(kd, self.key(['d.bend']))

    def test_hub_package_file_is_in_the_closure(self):
        k = self.key(['a.bend'])
        self.w('lib/0xabc/p.bend', 'import Base\n# changed\n')
        self.assertNotEqual(k, self.key(['a.bend']))

    def test_settings_and_checker_are_in_the_key(self):
        self.assertNotEqual(self.key(['a.bend'], 'stack=1'), self.key(['a.bend'], 'stack=2'))
        self.assertNotEqual(UC.key(['a.bend'], '', ident='x'), UC.key(['a.bend'], '', ident='y'))

    def test_unresolvable_import_is_not_cacheable(self):
        self.w('e.bend', 'import Base\nimport ./missing.bend as M\n')
        with self.assertRaises(UC.NotCacheable):
            self.key(['e.bend'])
        self.w('f.bend', 'import Base\nimport name@1.0/x.bend as N\n')
        with self.assertRaises(UC.NotCacheable):
            self.key(['f.bend'])
        self.w('g.bend', 'import Base\nimport ./c.bend as C extra tokens\n')
        with self.assertRaises(UC.NotCacheable):
            self.key(['g.bend'])
        with self.assertRaises(UC.NotCacheable):
            self.key(['nonexistent.bend'])

    def test_import_after_the_header_is_still_read(self):
        k = self.key(['d.bend'])
        self.w('d.bend', 'import Base\nimport ./c.bend as C\ndef x() -> U32: 1\nimport ./sub/b.bend as B\n')
        self.assertNotEqual(k, self.key(['d.bend']))
        self.w('c.bend', 'import Base\n# c\n')
        self.assertNotEqual(self.key(['d.bend']), k)

    def test_store_lookup_and_clear(self):
        k = self.key(['a.bend'])
        self.assertIsNone(UC.lookup(k))
        UC.store(k, ['a.bend'], 12.5, 800)
        e = UC.lookup(k)
        self.assertEqual((e['key'], e['seconds'], e['peak_mb'], e['roots']), (k, 12.5, 800, ['a.bend']))
        self.assertEqual(UC.clear(), 1)
        self.assertIsNone(UC.lookup(k))


if __name__ == '__main__':
    unittest.main()
