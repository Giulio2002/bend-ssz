#!/bin/bash
# tools/strictcheck.sh DIR [TARBALL_CACHE]: run ON THE SERVER (never on a laptop), it runs every generator and the fixture provenance check.
# every generator of codegen/ (the list: `python3 codegen/regen_all.py --list --paths`, from codegen/registry.py), with and without --no-big if supported; fails on nonzero exit or a failure word
# Output: one line per FAIL (red), a summary line (green when nothing failed), then `strictcheck-done`. Colors are on when stdout is a
# terminal or FORCE_COLOR=1, and off when NO_COLOR is set or the output is a pipe/file (so logs and `grep FAIL` stay plain).
cd ${1:-.}
TB=${2:-${CHECK_TARBALLS:-/srv/ssz-optimization/agents/tarball-cache}}
if { [ -t 1 ] || [ -n "${FORCE_COLOR:-}" ]; } && [ -z "${NO_COLOR:-}" ]; then
  RED=$'\033[1;31m'; GREEN=$'\033[1;32m'; YELLOW=$'\033[1;33m'; DIM=$'\033[2m'; OFF=$'\033[0m'
else
  RED=; GREEN=; YELLOW=; DIM=; OFF=
fi
pass=0; fail=0
fail_line() { fail=$((fail+1)); echo "${RED}FAIL${OFF} $1"; }
for g in $(python3 codegen/regen_all.py --list --paths); do
  for a in "" "--no-big"; do
    [ -n "$a" ] && ! grep -q -- "--no-big" $g && continue
    out=$(python3 $g --check $a 2>&1); rc=$?
    if [ $rc -ne 0 ] || echo "$out" | grep -qiE "stale|traceback|error|orphan|left after|fail|not found|mismatch"; then
      fail_line "rc=$rc $g $a: $(echo "$out" | tail -2 | tr '\n' ' ' | cut -c1-300)"
    else
      pass=$((pass+1)); [ -n "${VERBOSE:-}" ] && echo "${GREEN}ok${OFF}   ${DIM}$g $a${OFF}"
    fi
  done
done
# fixture provenance: the committed fixtures and the manifest against the pinned release tarballs (cached)
if [ -f tools/verify_fixtures.py ]; then
  out=$(python3 tools/verify_fixtures.py --tarballs $TB 2>&1); rc=$?
  if [ $rc -ne 0 ] || echo "$out" | grep -qiE "mismatch|traceback|error"; then
    fail_line "rc=$rc tools/verify_fixtures.py --tarballs: $(echo "$out" | tail -2 | tr '\n' ' ' | cut -c1-300)"
  else
    pass=$((pass+1)); [ -n "${VERBOSE:-}" ] && echo "${GREEN}ok${OFF}   ${DIM}tools/verify_fixtures.py --tarballs${OFF}"
  fi
fi
if [ $fail -eq 0 ]; then echo "${GREEN}strictcheck: $pass checks passed, 0 failed${OFF}"; else echo "${YELLOW}strictcheck: $pass checks passed, ${RED}$fail failed${OFF}"; fi
echo strictcheck-done
