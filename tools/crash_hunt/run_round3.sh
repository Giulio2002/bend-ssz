#!/bin/bash
# tools/crash_hunt/run_round3.sh: how the round-3 campaigns were run (docs/CRASH_HUNT.md, section "Round 3"). Run ON THE SERVER from the repository
# root, with the consensus-specs checkout CS (see tools/spec_audit/run_all.sh). Everything runs at nice 19, at most 4 programs at a time; the generated
# programs (tools/crash_hunt/{pd,cd,lie,st}/, mb_*.bend) are not committed, the generators rebuild them.
set -u
cd "$(dirname "$0")/../.." || exit 2
CS=${CS:-/srv/ssz-optimization/agents/specaudit/cs}
BEND=${BEND:-/srv/ssz-optimization/toolchain-memo-788a6866/bin/bend}
ulimit -s 16384; export BEND_NO_TELEMETRY=1
mkdir -p build/ch out
comp() { BUN_JSC_forceRAMSize=3000000000 nice -n 19 timeout 900 "$BEND" "$1" -o "build/ch/$(basename "$1" .bend)" > "out/comp_$(basename "$1" .bend).log" 2>&1 && echo "ok $1" || echo "FAIL $1"; }
export -f comp; export BEND
# (c) hostile decode at scale: real containers and the variable-size generic types
for n in BeaconState BeaconBlockBody SignedBeaconBlock; do python3 tools/crash_hunt/gen_mutbatch.py --name $n --out tools/crash_hunt/mb_$n.bend; done
for n in BitsStruct CompatibleUnionABCA CompatibleUnionA CompatibleUnionBC ComplexTestStruct ProgressiveComplexTestStruct ProgressiveSingleListContainerTestStruct ProgressiveTestStruct ProgressiveVarTestStruct VarTestStruct; do
  python3 tools/crash_hunt/gen_mutbatch.py --generic --name $n --out tools/crash_hunt/mb_$n.bend; done
ls tools/crash_hunt/mb_*.bend | xargs -P 3 -n 1 bash -c 'comp "$0"'
for n in SignedBeaconBlock BeaconBlockBody BeaconState; do
  python3 tools/crash_hunt/mutate_batch.py --repo . --cs "$CS" --name $n --per-seed 90000 --seeds zero,rand0,rand1,rand2 --chunk 5000 --jobs 2 --root-every 20 --ref-limit 5000 --out out/c_$n; done
# (b) differential tests: packed collections, cached roots, setters; (a) lying objects into every entry point
python3 tools/crash_hunt/gen_packed_diff.py gen --repo . --out tools/crash_hunt/pd
python3 tools/crash_hunt/gen_cache_diff.py gen --repo . --out tools/crash_hunt/cd
python3 tools/crash_hunt/gen_setters.py gen --repo . --cs "$CS" --out tools/crash_hunt/st
python3 tools/crash_hunt/gen_lie.py gen --repo . --out tools/crash_hunt/lie
ls tools/crash_hunt/pd/*.bend tools/crash_hunt/cd/*.bend tools/crash_hunt/st/*.bend tools/crash_hunt/lie/*.bend | xargs -P 3 -n 1 bash -c 'comp "$0"'
python3 tools/crash_hunt/gen_packed_diff.py run --repo . --out out/pd --jobs 2
python3 tools/crash_hunt/gen_cache_diff.py run --repo . --cs "$CS" --out out/cd --jobs 3
python3 tools/crash_hunt/gen_setters.py run --repo . --cs "$CS" --out out/st --jobs 2
python3 tools/crash_hunt/gen_lie.py run --repo . --out out/lie --jobs 3
# hand probes (compile each with comp, run with tools/crash_hunt/run_cases.sh build/ch/<name> "<case> <arg>" ...): pl_r3 pm_r3 pa3_r3 ph3_r3 pd3_r3 pr_r3 pk_r3
