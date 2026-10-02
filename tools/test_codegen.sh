#!/bin/bash
# tools/test_codegen.sh [JOBS]: the generators' unit tests, the lint, and the byte-for-byte check of every generated
# file. Run ON THE SERVER (regenerate_all --check reads the whole tree and runs every generator); the unit tests and the
# lint are light and also run on a laptop (`python3 -m unittest discover codegen/tests -t .`, `ruff check codegen`).
set -e
cd "$(dirname "$0")/.."
python3 -m unittest discover codegen/tests -t .
if command -v ruff >/dev/null 2>&1; then ruff check codegen; else echo "ruff not installed: lint skipped"; fi
python3 codegen/regenerate_all.py --check -j "${1:-8}"
