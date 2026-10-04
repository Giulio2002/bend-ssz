#!/bin/bash
# build_dirty.sh: compile tools/crash_hunt/r5/dirty/dt_*.bend into build/ch5 (server, pinned toolchain, 3 at a time, nice 19).
cd "$(dirname "$0")/../../.." || exit 2
mkdir -p build/ch5
export BEND_NO_TELEMETRY=1 BUN_JSC_forceRAMSize=3000000000
BEND=${BEND:-/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend}
ls tools/crash_hunt/r5/dirty/dt_*.bend | xargs -P 3 -I{} bash -c 'f={}; b=$(basename $f .bend); nice -n 19 timeout 900 '"$BEND"' $f -o build/ch5/$b > build/ch5/$b.log 2>&1 || echo "compile failed $b"'
