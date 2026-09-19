"""Infrastructure failures must never count as official invalid-case rejection."""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('spectests', ROOT / 'tools/spectests.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


class TransportFailureTests(unittest.TestCase):
    def run_failure(self, response):
        with tempfile.TemporaryDirectory(dir=ROOT / 'build') as directory:
            report = Path(directory) / 'report.json'
            with patch('sys.argv', ['spectests', '--report', str(report)]), \
                 patch.object(runner.subprocess, 'run', side_effect=response), \
                 contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(runner.main(), 1)
            result = json.loads(report.read_text())
            self.assertEqual([r['case'] for r in result['cases']],
                             json.loads((ROOT / 'cases.json').read_text()))
            self.assertEqual(result['passed'], 0)
            self.assertTrue(all(r['status'] == 'failed' for r in result['cases']))

    def test_interrupt_preserves_inventory_and_nonzero_status(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'build') as directory:
            report = Path(directory) / 'report.json'
            with patch('sys.argv', ['spectests', '--report', str(report)]), \
                 patch.object(runner.subprocess, 'run', side_effect=KeyboardInterrupt), \
                 contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(runner.main(), 130)
            result = json.loads(report.read_text())
            self.assertFalse(result['evidence']['complete'])
            self.assertEqual(result['passed'], 0)
            self.assertEqual([r['case'] for r in result['cases']],
                             json.loads((ROOT / 'cases.json').read_text()))
            self.assertTrue(all(r['status'] == 'failed' for r in result['cases']))

    def test_nonzero_backend_is_failure(self):
        self.run_failure(lambda *a, **k: SimpleNamespace(returncode=1, stderr='backend crashed', stdout=''))

    def test_timeout_is_failure(self):
        self.run_failure(runner.subprocess.TimeoutExpired('bend', 180))

    def test_structured_backend_error_is_not_rejection(self):
        def errors(*args, **kwargs):
            count = len(json.loads(kwargs['input']))
            return SimpleNamespace(returncode=0, stderr='',
                stdout=json.dumps([{'kind': 'backend_error', 'error': 'test'}] * count))
        self.run_failure(errors)

    def test_missing_backend_responses_fail(self):
        self.run_failure(lambda *a, **k: SimpleNamespace(returncode=0, stderr='', stdout='[]'))


if __name__ == '__main__':
    unittest.main()
