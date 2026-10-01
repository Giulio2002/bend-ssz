#!/bin/bash
# tools/run_evidence.sh: refresh the runtime evidence (benchmarks/evidence/*.json) on the ssz server from this checkout.
#
# Refuses to run on a dirty checkout, so every stamp records a clean commit (benchmarks/checks/provenance.py).
# Rsyncs the tree to $EV_DIR on the server (no .git: the stamps get the commit, the dirty flag and the tree hash from
# EVIDENCE_COMMIT / EVIDENCE_DIRTY / EVIDENCE_TREE, set here from the checkout), builds every native program through
# benchmarks/quick.py (cached, keyed by the compiler, Base, the flags and the import cone), runs every harness, and
# copies the evidence files back. Nothing runs on the machine this is started from. The programs a harness runs are
# hashed into its evidence file, together with the cache key each was built under.
#
#   tools/run_evidence.sh                      # all steps (about 12 minutes on the server)
#   STEPS='build fuzz' tools/run_evidence.sh   # some steps: build buildg buildf buildc conf gconf mut cache fuzz tmut inval neg rt
#
# Environment: EV_HOST (root@build-server.example), EV_DIR (/srv/ssz-optimization/agents/port-rigid/evidence),
# EV_BEND (the stock 2.0.34 bin/bend), EV_BUN, EV_PY (a python with the requirements).
set -eu
cd "$(git rev-parse --show-toplevel)"
if [ -n "$(git status --porcelain)" ]; then echo "run_evidence: the checkout is dirty; commit first" >&2; exit 2; fi
H=${EV_HOST:-root@build-server.example}
D=${EV_DIR:-/srv/ssz-optimization/agents/port-rigid/evidence}
BEND=${EV_BEND:-/srv/ssz-optimization/toolchain-2.0.34/bin/bend}
BUN=${EV_BUN:-/srv/ssz-optimization/toolchain-2.0.28/bun-linux-x64/bun}
PY=${EV_PY:-/srv/ssz-optimization/agents/rename-venv/bin/python}
ssh "$H" "mkdir -p $D"
rsync -a --delete --exclude=.git --exclude=build --exclude=__pycache__ --exclude=evlogs ./ "$H:$D/"
ssh "$H" "cd $D && export EVIDENCE_COMMIT=$(git rev-parse HEAD) EVIDENCE_DIRTY=0 EVIDENCE_TREE=$(git rev-parse 'HEAD^{tree}') BEND_RUNTIME=$BEND BEND_NO_TELEMETRY=1 BUN=$BUN
  mkdir -p build evlogs; : > evlogs/STATUS
  run() { n=\$1; shift; ( time nice -n 10 timeout 14400 \"\$@\" ) > evlogs/\$n.log 2>&1; echo \"\$n exit \$?\" >> evlogs/STATUS; }
  for s in \${STEPS:-${STEPS:-build buildg buildf buildc conf gconf mut cache fuzz tmut inval neg rt}}; do
    case \$s in
      build) run build $PY benchmarks/quick.py --build all;;
      buildg) run buildg $PY benchmarks/quick.py --build-generic all;;
      buildf) run buildf $PY benchmarks/quick.py --build-fuzz all;;
      buildc) run buildc $PY benchmarks/quick.py --build-compact;;
      conf) run conf $PY benchmarks/checks/object_conformance.py;;
      gconf) run gconf $PY benchmarks/checks/generic_object_conformance.py;;
      mut) run mut $PY benchmarks/checks/object_mutations.py;;
      cache) run cache $PY benchmarks/checks/object_cache.py;;
      fuzz) run fuzz $PY tests_generated/fuzz_objects.py;;
      tmut) run tmut $PY tests_generated/mutations.py;;
      inval) run inval $PY tests_generated/invalid_objects.py;;
      neg) run neg $PY tests_generated/negative_api.py;;
      rt) run rt $PY tools/run_runtime_tests.py;;
    esac
  done; echo finished >> evlogs/STATUS; cat evlogs/STATUS"
rsync -a --include='*.json' --exclude='*' "$H:$D/benchmarks/evidence/" benchmarks/evidence/
python3 benchmarks/checks/provenance.py
