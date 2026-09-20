"""Frozen root-domain completion gate; semantic meaning requires independent audit."""
from pathlib import Path
import re,subprocess,sys
root=Path(__file__).resolve().parents[1]
p=root/'ROOT_DOMAIN.bend'
if not p.exists():raise SystemExit('INCOMPLETE: ROOT_DOMAIN.bend is required')
s=p.read_text()
for law in ['full_root_correct','serializable_root_compatibility','root_domain_strictly_broader']:
 if not re.search(r'^law '+law+r'\s*:',s,re.M):raise SystemExit('INCOMPLETE: missing '+law)
# Test names only establish discoverability. The auditor must inspect types,
# implementation linkage, hypotheses and independent normative domain.
if './ROOT_DOMAIN.bend' not in (root/'PROOF.bend').read_text():raise SystemExit('ROOT_DOMAIN must be imported by PROOF.bend')
subprocess.run([sys.executable,'automation/acceptance.py'],cwd=root,check=True)
