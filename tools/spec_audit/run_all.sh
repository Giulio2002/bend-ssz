#!/bin/bash
# tools/spec_audit/run_all.sh: the whole specification audit, end to end, on the ssz server (never on a laptop).
#
#   cd <repository root on the server> && tools/spec_audit/run_all.sh [WORKDIR]
#
# Needs: git and internet (or a copy of consensus-specs at the tag in WORKDIR/cs), python3, the native object programs
# built by `benchmarks/quick.py --build-generic all` and `--build all` (see docs/SPEC_AUDIT.md), the pinned checker
# (tools/check.sh). The remerkleable second reference needs python 3.10-3.12; if /tmp/sa312 is missing this script creates it
# with uv (pip install uv; uv python install 3.12) under /tmp (tmpfs: nothing is left on the disk).
set -eu
W=${1:-/tmp/specaudit}; R=$(pwd); mkdir -p "$W"
TAG=$(python3 -c "import json;print(json.load(open('upstream.lock.json'))['consensus_specs']['tag'])")
COMMIT=$(python3 -c "import json;print(json.load(open('upstream.lock.json'))['consensus_specs']['commit'])")
if [ ! -d "$W/cs" ]; then git clone -q --depth 1 --branch "$TAG" https://github.com/ethereum/consensus-specs.git "$W/cs"; fi
[ "$(git -C "$W/cs" rev-parse HEAD)" = "$COMMIT" ] || { echo "consensus-specs checkout is not $COMMIT" >&2; exit 2; }
CS=$W/cs
echo "== 1. constants and schemas"
python3 tools/spec_audit/constants.py --repo . --cs "$CS" --out tools/spec_audit/data
tools/spec_audit/selftest.sh "$CS"
echo "== 1b. the port against the official vectors (needs the release tarballs: python-snappy, ruamel.yaml in PY)"
FX=$W/fx; TC=${TARBALLS:-/srv/ssz-optimization/agents/tarball-cache}; PY=${PY:-/srv/ssz-optimization/agents/rename-venv/bin/python}
if [ ! -d "$FX/tests" ]; then mkdir -p "$FX"; tar xzf "$TC/general.tar.gz" -C "$FX" --wildcards 'tests/general/phase0/ssz_generic/*'; tar xzf "$TC/mainnet.tar.gz" -C "$FX" --wildcards 'tests/mainnet/fulu/ssz_static/*'; fi
"$PY" tools/spec_audit/official_vectors.py --repo . --cs "$CS" --fx "$FX"
echo "== 2. differential corpus from the reference port"
python3 tools/spec_audit/cases.py --repo . --cs "$CS" --out "$W/cases" --per-type 400
echo "== 3. Bend object programs (needs build/obj-x*, build/obj-g*)"
python3 tools/spec_audit/run_bend.py --repo . --cases "$W/cases/cases.jsonl" --out "$W/cases" --jobs 6 || true
python3 tools/spec_audit/selftest_run.py "$W/cases/cases.jsonl" "$W/selftest"
echo "== 4. second reference: remerkleable at the pinned commit"
if [ ! -x /tmp/sa312/bin/python ]; then
  python3 -m venv /tmp/sa-uv && /tmp/sa-uv/bin/pip install -q uv && UV_PYTHON_INSTALL_DIR=/tmp/uvpy /tmp/sa-uv/bin/uv python install 3.12
  /tmp/uvpy/cpython-3.12*/bin/python3.12 -m venv /tmp/sa312
  git clone -q https://github.com/ethereum/remerkleable /tmp/rk && git -C /tmp/rk checkout -q 667eab00ecc3c25682c754dd72ad164fa8c1750e
  /tmp/sa312/bin/pip install -q /tmp/rk
fi
/tmp/sa312/bin/python tools/spec_audit/rk_oracle.py --repo . --cs "$CS" --cases "$W/cases/cases.jsonl" --out "$W/cases"
/tmp/sa312/bin/python tools/spec_audit/progressive_reading.py "$CS"
echo "== 5. spec-level proofs by computation (tools/check.sh, every file <= 120 s)"
python3 tools/spec_audit/specgen.py --repo . --cs "$CS" --cases "$W/cases/cases.jsonl" --out tools/spec_audit/spec_cases
tools/spec_audit/run_spec_cases.sh 2 "$W/spec-logs"
python3 tools/spec_audit/summarize.py "$W/cases" tools/spec_audit/data "$W/spec-logs"
