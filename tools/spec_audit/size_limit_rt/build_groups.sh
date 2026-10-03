#!/bin/bash
# build_groups.sh TREE [JOBS]: compile the object programs of every group (benchmarks/objprog/{g,x}<k>_generated.bend) of TREE into
# TREE/build/obj-{g,x}<k> with the runtime compiler (the 2.0.34 release), JOBS at a time (default 4) at nice 19. Server only.
T=${1:?tree}; J=${2:-4}
BEND=${BEND_RUNTIME:-/srv/ssz-optimization/toolchain-2.0.34/bin/bend}
cd "$T" || exit 2
mkdir -p build
ls benchmarks/objprog/ | sed -n 's/^\([gx][0-9]*\)_generated.bend$/\1/p' | xargs -P "$J" -I{} bash -c '
  s=$(date +%s)
  BEND_NO_TELEMETRY=1 BUN_JSC_forceRAMSize=3000000000 nice -n 19 '"$BEND"' benchmarks/objprog/{}_generated.bend -o build/obj-{} > build/obj-{}.log 2>&1
  echo "{} rc=$? $(( $(date +%s) - s )) s"'
