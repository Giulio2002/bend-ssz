#!/bin/bash
# tools/strictcheck.sh DIR [TARBALL_CACHE]: run ON THE SERVER (never on a laptop), it runs every generator and the fixture provenance check.
# every codegen/*.py that accepts --check (except regen_all), with and without --no-big if supported; fails on nonzero exit or a failure word
cd ${1:-.}
TB=${2:-${CHECK_TARBALLS:-/srv/ssz-optimization/agents/tarball-cache}}
for g in codegen/*.py; do
  grep -q -- "--check" $g || continue; case $g in codegen/regen_all.py) continue;; esac
  for a in "" "--no-big"; do
    [ -n "$a" ] && ! grep -q -- "--no-big" $g && continue
    out=$(python3 $g --check $a 2>&1); rc=$?
    if [ $rc -ne 0 ] || echo "$out" | grep -qiE "stale|traceback|error|orphan|left after|fail|not found|mismatch"; then
      echo "FAIL rc=$rc $g $a: $(echo "$out" | tail -2 | tr '\n' ' ' | cut -c1-300)"
    fi
  done
done
# fixture provenance: the committed fixtures and the manifest against the pinned release tarballs (cached)
if [ -f tools/verify_fixtures.py ]; then
  out=$(python3 tools/verify_fixtures.py --tarballs $TB 2>&1); rc=$?
  if [ $rc -ne 0 ] || echo "$out" | grep -qiE "mismatch|traceback|error"; then
    echo "FAIL rc=$rc tools/verify_fixtures.py --tarballs: $(echo "$out" | tail -2 | tr '\n' ' ' | cut -c1-300)"
  fi
fi
echo strictcheck-done
