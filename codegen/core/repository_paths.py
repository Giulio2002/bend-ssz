"""The repository's directories, in one place: every generator imports its roots from here instead of
recomputing them from its own file's depth."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]      # the repository root
CODEGEN = ROOT / 'codegen'
TEMPLATES = CODEGEN / 'templates'                # the .bend.in files the generators copy or fill
TOOLS = ROOT / 'tools'
OBJ = ROOT / 'proofs/obj'                        # the laws of the generated functions and their libraries
E2E = ROOT / 'e2e'                               # the bridges, the composed theorems, the witnesses
TYPES = ROOT / 'types'                           # the typed object API
SCHEMA_YAML = CODEGEN / 'fulu.yaml'              # the Fulu schema every generator starts from

# the `_generated` suffix of generated file names: a generator process (a script under codegen/) sees the stem names through the view of
# codegen/core/generated_names.py; tools, tests and the checker, which import codegen modules too, see the real names on disk
from codegen.core import generated_names as _generated_names  # noqa: E402

_generated_names.install_for_generators()
