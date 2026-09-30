import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('run_evidence',ROOT/'tools/run_evidence.py')
e=importlib.util.module_from_spec(spec)
spec.loader.exec_module(e)
class Reports(unittest.TestCase):
    def test_subsequent_failure_preserves_success(self):
        with tempfile.TemporaryDirectory() as directory:
            latest=Path(directory)/'report.json'
            first={'evidence':{'run_id':'first'},'passed':5440,'failed':0}
            second={'evidence':{'run_id':'second'},'passed':5439,'failed':1}
            a=e.preserve_report(first,latest);original=a.read_bytes()
            b=e.preserve_report(second,latest)
            self.assertNotEqual(a,b)
            self.assertEqual(a.read_bytes(),original)
            self.assertEqual(json.loads(latest.read_text()),second)
            sidecar=json.loads(latest.with_suffix('.json.provenance.json').read_text())
            self.assertEqual(sidecar['sha256'],e.sha256_file(b))
            self.assertEqual(e.preserve_report(first,latest),a)
    def test_corruption_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            latest=Path(directory)/'report.json';r={'evidence':{'run_id':'test'}}
            archive=e.preserve_report(r,latest);archive.write_bytes(b'corrupt')
            with self.assertRaisesRegex(RuntimeError,'content mismatch'):e.preserve_report(r,latest)
if __name__=='__main__':unittest.main()
