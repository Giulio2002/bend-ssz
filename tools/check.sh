#!/bin/bash
# tools/check.sh <file.bend> [bend args]: check one file with the pinned checker (toolchain.lock.json)
# under the limits the proofs were measured with:
# 12 GB memory (no swap), 2 CPUs at nice 10, 600 s. Prints the checker's output, then
# "CHECK_TIME <seconds> <peak KB>". Run from the repository root.
#
# The toolchain is found through the environment (defaults: the ssz server's layout):
#   BEND_TOOLCHAIN  a release layout (bin/bend, the compiled checker, and bend2/base.bend) or a
#                   source layout (bun-linux-x64/bun and bend-src/bend2/main.ts)
#   BEND_LIB        BendHub package cache (the SHA-256 dependency); default vendor/bendhub
#   BEND_LOCK       the toolchain lock to verify against; default toolchain.lock.json
#   CHECK_STACK_KB  the stack limit (ulimit -s) of the check; default 16384
#   CHECK_JSC_STACK the JavaScriptCore stack budget (BUN_JSC_maxPerThreadStackUsage, bytes); default
#                   10485760 (10 MB; JSC's own default is 5 MB). Both are pinned so that a shell's or an environment's
#                   limits never change a result: the checker recurses once per level of a
#                   conversion, and JSC stops at the smaller of the two (at 16384 KB, its 10 MB budget). The two are printed as the first line of every log.
#                   tools/check_fast.sh --jsc-stack runs the informational headroom run (a full check at another budget).
# Before running, tools/verify_pins.py checks the checker's files, bun and the package against
# toolchain.lock.json and refuses to run on a mismatch (CHECK_PINS_VERIFIED=1 skips it: check_fast.sh
# verifies once for all its runs).
set -u
R=$(cd "$(dirname "$0")/.." && pwd)
[ $# -ge 1 ] || { echo "usage: tools/check.sh <file.bend> [bend args]" >&2; exit 2; }
T=${BEND_TOOLCHAIN:-/srv/ssz-optimization/toolchain-memo-788a6866}
if [ -x "$T/bin/bend" ] && [ -f "$T/bend2/base.bend" ]; then
  CHK=("$T/bin/bend")
elif [ -x "$T/bun-linux-x64/bun" ] && [ -f "$T/bend-src/bend2/main.ts" ]; then
  CHK=("$T/bun-linux-x64/bun" "$T/bend-src/bend2/main.ts")
else
  echo "checker not found under $T (set BEND_TOOLCHAIN)" >&2; exit 2
fi
BEND_LIB=${BEND_LIB:-$R/vendor/bendhub}
LOCK=${BEND_LOCK:-$R/toolchain.lock.json}
if [ "${CHECK_PINS_VERIFIED:-}" != 1 ]; then
  python3 "$R/tools/verify_pins.py" --lock "$LOCK" --toolchain "$T" --lib "$BEND_LIB" >&2 || { echo "check.sh: toolchain does not match $LOCK" >&2; exit 3; }
fi
f=$1; shift
[ $# -eq 0 ] && set -- --check-only
export BEND_NO_TELEMETRY=1 BUN_JSC_forceRAMSize=${BUN_JSC_forceRAMSize:-8000000000}
export BEND_LIB
MEM=${CHECK_MEMMAX:-12G} CPU=${CHECK_CPUS:-2} TMO=${CHECK_TIMEOUT:-600}
STK=${CHECK_STACK_KB:-16384}
ulimit -s "$STK" 2>/dev/null || { echo "check.sh: cannot set the stack limit to $STK KB (ulimit -s)" >&2; exit 2; }
export BUN_JSC_maxPerThreadStackUsage=${CHECK_JSC_STACK:-10485760}
echo "CHECK_STACK ulimit_kb=$STK jsc_bytes=$BUN_JSC_maxPerThreadStackUsage"
cmd=(nice -n 10 timeout "$TMO" /usr/bin/time -f "CHECK_TIME %e %M" "${CHK[@]}" "$f" "$@")
if command -v systemd-run >/dev/null 2>&1 && [ "$(id -u)" = 0 ]; then
  exec systemd-run --quiet --scope -p MemoryMax="$MEM" -p MemorySwapMax=0 -p CPUQuota=$((CPU * 100))% "${cmd[@]}"
elif command -v systemd-run >/dev/null 2>&1 && systemd-run --user --scope true >/dev/null 2>&1; then
  exec systemd-run --user --quiet --scope -p MemoryMax="$MEM" -p MemorySwapMax=0 -p CPUQuota=$((CPU * 100))% "${cmd[@]}"
else
  # no cgroup control: the time limit and nice still apply, memory and CPU are not capped
  echo "check.sh: systemd-run unavailable, memory/CPU limits not enforced" >&2
  exec "${cmd[@]}"
fi
