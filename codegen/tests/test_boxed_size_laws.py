"""The slop generators that read the boxed size pass of a generated type by regex must keep finding every one.

CH-12 changed the empty-box case of `X_bx_size` from `(X_bx_default(), 0)` to `(O.BNone{}, 0)`; two generators matched the old text
and silently stopped emitting ten law modules. These tests require that every boxed size pass whose size is computed (a `_size_back`
case) is found by both regexes, and that the laws they emit are on disk for the types the pass belongs to.
"""
import re
import unittest

from codegen.core.repository_paths import ROOT
from codegen.proofs.slop import decoder_offsets, write_start_and_sizes

PASS = re.compile(r'^def \w+_bx_size\(o: O\.Boxed<[^\n]+?>\) -> [^\n]*:\n  match o:\n    case O\.BSome\{v, rest\}: \w+_bx_size_back\(.*\n    case O\.BNone\{\}: [^\n]*$', re.M)


def passes():
    for p in sorted((ROOT / 'types').glob('*_encode_ssz_generated.bend')):
        for m in PASS.finditer(p.read_text()):
            yield p.name, m.group(0)


class BoxedSizeLawsTest(unittest.TestCase):
    def test_both_regexes_find_every_computed_boxed_size_pass(self):
        found = list(passes())
        self.assertGreaterEqual(len(found), 3, 'no computed boxed size pass found: the pattern in this test is stale')
        for name, text in found:
            self.assertRegex(text, decoder_offsets.BXM.pattern, f'{name}: decoder_offsets.BXM does not read this boxed size pass')
            last = text.split('\n')[-1]
            self.assertTrue(write_start_and_sizes.BX_NONE_ZERO.search(last), f'{name}: write_start_and_sizes does not read {last}')

    def test_the_laws_are_on_disk(self):
        for d in ('slop', 'gate/slop'):
            for n in ('VarTestStruct', 'ProgressiveVarTestStruct', 'Transaction'):
                text = (ROOT / 'proofs' / d / 'size' / f'{n}_generated.bend').read_text()
                self.assertIn('_ms_bxsize_', text, f'{d}/size/{n}: no boxed size law')
            for n in ('Deposit', 'ProposerSlashing'):
                text = (ROOT / 'proofs' / d / 'offsets' / f'{n}_reported_size_generated.bend').read_text()
                self.assertIn('_bx_size(O.BNone{})', text, f'{d}/offsets/{n}_reported_size: no boxed size law')


if __name__ == '__main__':
    unittest.main()
