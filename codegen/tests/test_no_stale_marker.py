"""No generated runtime file and no source file carries the old 2^31 invalid-size marker (docs/SIZE_LIMIT_DESIGN.md).

The size pass reports an invalid object as the marker 4294967295 and `O.is_poisoned` reads every size above NMAX = 4294967264. A writer that
still returned 2147483648 (the old bit-31 flag) would have its invalid object ACCEPTED by `_serialize`. The only legitimate uses of the
literal 2147483648 in types/ and src/ are listed here; the generated laws (proofs/slop/validity/*_marker_poison, crash_fix_laws) pin the marker too.
"""
import re
import unittest

from codegen.core.repository_paths import ROOT

# (file name, the line pattern) of the legitimate uses: the padding bit of a bit vector word and the mask of the top bit of a bit list word
ALLOWED = (
    (re.compile(r'^bitvector_\d+_encode_ssz_generated\.bend$'), re.compile(r'U32\.is_lt\(w\d+, 2147483648\)')),
    (re.compile(r'^bitvector_\d+_def_generated\.bend$'), re.compile(r'\.&\. 2147483647 : U32')),
    (re.compile(r'^obj\.bend$'), re.compile(r'\(x \.&\. 2147483648 : U32\), 0\)')),
)
STALE = re.compile(r'\b2147483648\b|\b2147483647\b')


class StaleMarkerTest(unittest.TestCase):
    def test_no_old_marker_literal(self):
        files = sorted((ROOT / 'types').glob('*.bend')) + sorted((ROOT / 'src').glob('*.bend'))
        self.assertGreater(len(files), 100)
        bad = []
        for p in files:
            for i, line in enumerate(p.read_text().split('\n'), 1):
                if STALE.search(line) and not any(f.match(p.name) and l.search(line) for f, l in ALLOWED):
                    bad.append(f'{p.name}:{i}: {line.strip()[:100]}')
        self.assertFalse(bad, 'the old 2^31 marker literal is back: ' + '; '.join(bad[:5]))


if __name__ == '__main__':
    unittest.main()
