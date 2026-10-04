#!/bin/bash
# build_chain.sh K...: compile the round-5 chain driver of fuzz groups K (server, pinned toolchain, nice 19) into build/ch5/chain-f<K>.
cd "$(dirname "$0")/../../.." || exit 2
mkdir -p build/ch5 tools/crash_hunt/r5/gen
export BEND_NO_TELEMETRY=1 BUN_JSC_forceRAMSize=3000000000
BEND=${BEND:-/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend}
for k in "$@"; do
  sed "s/@K@/$k/g" tools/crash_hunt/r5/chain.bend.in > tools/crash_hunt/r5/gen/chain_f$k.bend
  nice -n 19 timeout 1500 "$BEND" tools/crash_hunt/r5/gen/chain_f$k.bend -o build/ch5/chain-f$k > build/ch5/chain-f$k.log 2>&1 || echo "compile failed $k"
done
