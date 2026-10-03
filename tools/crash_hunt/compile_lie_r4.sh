#!/bin/bash
# compile_lie_r4.sh: compile every tools/crash_hunt/lie/lie_<id>.bend into build/ch/lie_<id> (server, pinned toolchain, 3 at a time).
cd "$(dirname "$0")/../.." || exit 2
mkdir -p build/ch
export BEND_NO_TELEMETRY=1 BUN_JSC_forceRAMSize=3000000000
BEND=${BEND:-/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend}
ls tools/crash_hunt/lie/lie_*.bend | xargs -P 3 -I{} bash -c 'f={}; b=$(basename $f .bend); nice -n 19 timeout 900 '"$BEND"' $f -o build/ch/$b > build/ch/$b.log 2>&1 || echo "compile failed $b"'
ls build/ch/lie_* | grep -vc log
