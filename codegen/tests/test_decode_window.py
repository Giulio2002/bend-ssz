"""codegen/proofs/support/decode_window.py: the laws of X_decode over a window that is not a literal are moved to `_in` and carried by the lemma."""
import unittest

from codegen.proofs.support import decode_window as DW

NAMES = {'Checkpoint': 'FuluCheckpoint'}

HEAD = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../types/FuluCheckpoint_decode_ssz_generated.bend as FuluCheckpoint_r', '']


def wrap(*body):
    return DW.wrap('\n'.join(HEAD + list(body)) + '\n', NAMES)


class DecodeWindow(unittest.TestCase):
    def test_literal_window_is_untouched(self):
        t = '\n'.join(HEAD + ['def lit(+x: U32)',
                              '    -> {FuluCheckpoint_r.Checkpoint_decode(B.Buf{A, 40}, 40) == (B.Buf{A, 40}, None{}) : B.Buf & Maybe<&1, X>}:',
                              '  {==}', '']) + '\n'
        self.assertEqual(DW.wrap(t, NAMES), t)

    def test_symbolic_window_gets_the_reflexivity(self):
        out = wrap('def sym(+t: T, +n: U32)',
                   '    -> {FuluCheckpoint_r.Checkpoint_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, X>}:',
                   '  proof(t, n)', '')
        self.assertIn('def sym_in(', out)
        self.assertIn('Checkpoint_decode_in(BF(t, n), n)', out)
        self.assertIn('DW_FuluCheckpoint.Checkpoint_win_some(BF(t, n), n, (BF(t, n), Some{OBJ(t, n)}), DWL.le_refl(n), sym_in(t, n))', out)
        self.assertIn('import ../../proofs/obj/decode_window_FuluCheckpoint_generated.bend as DW_FuluCheckpoint', out)
        self.assertEqual(DW.wrap(out, NAMES), out)        # idempotent

    def test_free_buffer_refusal_is_carried_for_every_window(self):
        out = wrap('def rej(buf: B.Buf, +m: U32, e: {U32.is_eq(m, 40) == False{} : Bool})',
                   '    -> {FuluCheckpoint_r.Checkpoint_decode(buf, m) == (buf, None{}) : B.Buf & Maybe<&1, X>}:',
                   '  proof(m, e)', '')
        self.assertIn('Checkpoint_win_none_f(buf, m, b_ => rej_in(b_, m, e))', out)

    def test_a_result_over_a_free_buffer_needs_its_own_proof(self):
        with self.assertRaises(ValueError):
            wrap('def acc(buf: B.Buf, +m: U32)',
                 '    -> {FuluCheckpoint_r.Checkpoint_decode(buf, m) == (buf, Some{v}) : B.Buf & Maybe<&1, X>}:',
                 '  proof(m)', '')

    def test_laws_called_by_a_wrapped_law_are_called_as_in(self):
        out = wrap('def helper(+t: T, +n: U32)',
                   '    -> {FuluCheckpoint_r.Checkpoint_decode(BF(t, n), n) == (BF(t, n), None{}) : B.Buf & Maybe<&1, X>}:',
                   '  {==}', '',
                   'def user(+t: T, +n: U32)',
                   '    -> {FuluCheckpoint_r.Checkpoint_decode(BF(t, n), n) == (BF(t, n), None{}) : B.Buf & Maybe<&1, X>}:',
                   '  helper(t, n)', '')
        self.assertIn('  helper_in(t, n)', out)


if __name__ == '__main__':
    unittest.main()
