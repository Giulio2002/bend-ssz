"""No list kind has an unguarded append (docs/CRASH_HUNT.md CH-04, R2-01, R2-06).

An append computes the new length `(n + 1) * element size`, and a byte list rounds it up to a chunk: both wrap in U32 for a claimed
count near 2^32. A list whose limit exceeds U32 used to leave the guard `True{}`, so these tests read every generated list type and
require the guard of every append to be a comparison of the count with a bound below which neither the length nor its rounding wraps.
"""
import re
import unittest

from codegen.core.repository_paths import ROOT

TYPES = ROOT / 'types'
CALL = re.compile(r'^\s+(?:case [^:]*: )?\w+_(grow|push|app_in|capp_in)\((.*)$', re.M)


def list_types():
    for p in sorted(TYPES.glob('*_def_generated.bend')):
        text = p.read_text()
        if re.search(r'^def \w+_append\(', text, re.M):
            yield p, text


class AppendGuardTest(unittest.TestCase):
    def test_every_list_has_an_append_guard(self):
        kinds = list(list_types())
        self.assertGreater(len(kinds), 40, 'the generated list types were not found')
        for p, text in kinds:
            calls = CALL.findall(text)
            self.assertTrue(calls, f'{p.name}: no append found')
            for fn, rest in calls:
                self.assertFalse(rest.startswith('True{}'), f'{p.name}: {fn} with the guard True{{}}')
                self.assertRegex(rest, r'^(?:Bool\.and\()*U32\.is_lt\(', f'{p.name}: the guard of {fn} is not a count comparison: {rest[:80]}')
                # and the storage test: the object may claim more elements than its array holds (docs/CRASH_HUNT.md R3-02)
                self.assertRegex(rest, r'U32\.is_le\([^\n]*\bsc\)', f'{p.name}: the guard of {fn} does not test the storage: {rest[:120]}')

    def test_guard_bounds_keep_the_length_below_the_chunk_wrap(self):
        """for a packed list of es-byte elements, n < bound implies (n + 1) * es + 31 < 2^32"""
        checked = 0
        for p, text in list_types():
            es = re.search(r'\(\(n \+ 1 : U32\) \* (\d+) : U32\)', text)
            m = re.search(r'_grow\((?:Bool\.and\()*U32\.is_lt\(n, (\d+)\)', text)
            if es is None or m is None:
                continue
            self.assertLess(int(m.group(1)) * int(es.group(1)) + 31, 1 << 32, f'{p.name}: the guard bound {m.group(1)} lets the length wrap')
            checked += 1
        self.assertGreater(checked, 10)

    def test_composite_count_bound_keeps_the_encoding_below_2_31_bytes(self):
        """for a list of fixed-size composites, the append guard bound B satisfies B * es < 2^31: the size, validity and writer arithmetic is U32,
        and n * es wraps from n = 2^32 / es (docs/CRASH_HUNT.md R3-03)"""
        checked = 0
        for p in sorted(TYPES.glob('*_def_generated.bend')):
            text = p.read_text()
            m = re.search(r'^def \w+_app_sz\(.*\n.*\n  \w+_app_in\(Bool\.and\(U32\.is_lt\(n, (\d+)\), U32\.is_le\(n, sc\)\), arr, n, v\)', text, re.M)
            enc = TYPES / p.name.replace('_def_', '_encode_ssz_')
            if m is None or not enc.exists():
                continue
            es = re.search(r'O\.pick\(U32\.is_le\(n, c\), O\.mulc\(n, (\d+)\), 4294967295\)', enc.read_text())
            if es is None:
                continue
            self.assertLessEqual(int(m.group(1)) * int(es.group(1)), 4294967264, f'{p.name}: the guard bound {m.group(1)} lets n * {es.group(1)} exceed NMAX')
            checked += 1
        self.assertGreater(checked, 5)


if __name__ == '__main__':
    unittest.main()
