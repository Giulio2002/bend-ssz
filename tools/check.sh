#!/bin/bash
# tools/check.sh <file.bend> [bend args]: check one file with the pinned checker (Bend 2.0.28 +
# bendlang/bend#1075 with its budget fix) under the limits the proofs were measured with:
# 12 GB memory (no swap), 2 CPUs at nice 10, 600 s. Prints the checker's output, then
# "CHECK_TIME <seconds> <peak KB>". Run from the repository root.
#
# The toolchain is found through the environment (defaults: the ssz server's layout):
#   BEND_TOOLCHAIN  directory holding bun-linux-x64/bun and bend-src/bend2/main.ts
#   BEND_LIB        BendHub package cache (the SHA-256 dependency)
set -u
[ $# -ge 1 ] || { echo "usage: tools/check.sh <file.bend> [bend args]" >&2; exit 2; }
T=${BEND_TOOLCHAIN:-/srv/ssz-optimization/toolchain-2.0.28}
BUN=$T/bun-linux-x64/bun
MAIN=$T/bend-src/bend2/main.ts
[ -x "$BUN" ] && [ -f "$MAIN" ] || { echo "checker not found under $T (set BEND_TOOLCHAIN)" >&2; exit 2; }
f=$1; shift
[ $# -eq 0 ] && set -- --check-only
export BEND_NO_TELEMETRY=1 BUN_JSC_forceRAMSize=${BUN_JSC_forceRAMSize:-8000000000}
[ -n "${BEND_LIB:-}" ] && export BEND_LIB
MEM=${CHECK_MEMMAX:-12G} CPU=${CHECK_CPUS:-2} TMO=${CHECK_TIMEOUT:-600}
cmd=(nice -n 10 timeout "$TMO" /usr/bin/time -f "CHECK_TIME %e %M" "$BUN" "$MAIN" "$f" "$@")
if command -v systemd-run >/dev/null 2>&1 && [ "$(id -u)" = 0 ]; then
  exec systemd-run --quiet --scope -p MemoryMax="$MEM" -p MemorySwapMax=0 -p CPUQuota=$((CPU * 100))% "${cmd[@]}"
elif command -v systemd-run >/dev/null 2>&1 && systemd-run --user --scope true >/dev/null 2>&1; then
  exec systemd-run --user --quiet --scope -p MemoryMax="$MEM" -p MemorySwapMax=0 -p CPUQuota=$((CPU * 100))% "${cmd[@]}"
else
  # no cgroup control: the time limit and nice still apply, memory and CPU are not capped
  echo "check.sh: systemd-run unavailable, memory/CPU limits not enforced" >&2
  exec "${cmd[@]}"
fi
