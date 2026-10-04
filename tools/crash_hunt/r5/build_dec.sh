#!/bin/bash
# build_dec.sh K...: compile the round-5 decode-only driver of generic groups K into build/ch5/dec-g<K> (server, pinned toolchain, nice 19).
cd "$(dirname "$0")/../../.." || exit 2
mkdir -p build/ch5
export BEND_NO_TELEMETRY=1 BUN_JSC_forceRAMSize=3000000000
BEND=${BEND:-/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend}
for k in "$@"; do
  sed "s/@K@/$k/g" tools/crash_hunt/r5/dec_generic.bend.in > tools/crash_hunt/r5/dec_g$k.bend
  nice -n 19 timeout 1500 "$BEND" tools/crash_hunt/r5/dec_g$k.bend -o build/ch5/dec-g$k > build/ch5/dec-g$k.log 2>&1 || echo "compile failed $k"
done
