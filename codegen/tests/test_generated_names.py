"""Every generated .bend file carries `_generated` in its name, and the view of codegen/core/generated_names.py is a bijection."""
import os
import unittest

from codegen.core import generated_names as GN
from codegen.core.repository_paths import ROOT

SKIP = {'.git', 'build', 'node_modules', '__pycache__', 'vendor', 'fixtures', '.ruff_cache'}


class GeneratedNames(unittest.TestCase):
    def test_every_generated_file_is_named_generated(self):
        bad = []
        for dp, dns, fns in os.walk(ROOT):
            dns[:] = [d for d in dns if d not in SKIP]
            for f in fns:
                if not f.endswith('.bend') or f.endswith('_generated.bend'):
                    continue
                with open(os.path.join(dp, f), 'rb') as fh:
                    if b'# GENERATED' in fh.read(400):
                        bad.append(os.path.relpath(os.path.join(dp, f), ROOT))
        self.assertEqual(bad, [], 'generated files without _generated in their names (name them with the suffix): ' + ', '.join(bad[:10]))

    def test_the_list_names_files_on_disk(self):
        missing = [n for n in GN.NAMES if not (ROOT / GN.to_disk(n)).exists()]
        self.assertEqual(missing, [])
        self.assertTrue(all(not (ROOT / n).exists() for n in GN.NAMES), 'a stem name still exists on disk')

    def test_bijection(self):
        for n in GN.NAMES:
            self.assertEqual(GN.to_virtual(GN.to_disk(n)), n)

    def test_import_translation(self):
        t = 'import Base\nimport ./arr_copy.bend as AC\nimport ../../src/obj.bend as O\n'
        d = GN._translate(t, 'proofs/obj/x.bend', True)
        self.assertIn('import ./arr_copy_generated.bend as AC', d)
        self.assertIn('import ../../src/obj.bend as O', d)
        self.assertEqual(GN._translate(d, 'proofs/obj/x.bend', False), t)


if __name__ == '__main__':
    unittest.main()
