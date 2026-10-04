#!/bin/bash
# build_gchain.sh K...: compile the round-6 generic chain driver of generic fuzz groups K (server, scratch tree made by
# gen_generic_fuzz.py, pinned toolchain, nice 19) into build/ch6/gchain-f<K>.
cd "$(dirname "$0")/../../.." || exit 2
mkdir -p build/ch6
export BEND_NO_TELEMETRY=1 BUN_JSC_forceRAMSize=3000000000
BEND=${BEND:-/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend}
for k in "$@"; do
  sed "s/@K@/$k/g" tools/crash_hunt/r6/gchain.bend.in > tools/crash_hunt/r6/gchain_f$k.bend
  nice -n 19 timeout 1500 "$BEND" tools/crash_hunt/r6/gchain_f$k.bend -o build/ch6/gchain-f$k > build/ch6/gchain-f$k.log 2>&1 || echo "compile failed $k"
done
