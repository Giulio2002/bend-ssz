#!/bin/bash
# tools/iter.sh [--gen a,b] [--base REF] [-j N] [--no-regen] [--no-pull] [--cache] [files...]
#
# The DEV LOOP: fix, regenerate, check ONLY what changed, in minutes. It is not a gate: a merge needs
# the full tools/check_fast.sh (with localization) and strictcheck (docs/BUILD.md, "Fast iteration").
#
#   1. rsyncs this checkout (no .git, build/, node_modules) to a per-user server directory
#      (ITER_HOST, default root@build-server.example; ITER_DIR, default /srv/ssz-optimization/agents/iter-$USER);
#   2. there, runs `codegen/regenerate_all.py --touched` (only the generators whose inputs changed;
#      --gen a,b forces those generators too);
#   3. checks with tools/check.sh (the pinned checker, memory / CPU / stack / JSC limits as in a gate)
#      ONLY the .bend files that (a) differ from the git base locally (uncommitted + untracked; --base REF:
#      everything changed since REF), (b) the regeneration rewrote, (c) are named on the command line
#      (tools/ and vendor/ are skipped, as in check_fast.sh). No localization, no full-check lock, at most
#      -j (default 4) checks at once;
#   4. prints PASS/FAIL per file with seconds, the checker's failing location, and the log path; exit 1 on
#      any failure;
#   5. rsyncs the regenerated files back (the generators' exact output; --no-pull to skip).
#
# Environment: BEND_TOOLCHAIN etc. pass through to tools/check.sh (default: whatever check.sh defaults to on
# this branch, so it follows the port's rigid checker and stack settings). ITER_TIMEOUT (default 900 s per file).
#
# --cache: DEV MODULE CACHE. Uses /srv/ssz-optimization/toolchain-dev-cache (the rigid checker merged with
# bendlang/bend PR #1209) with BEND_CACHE, so modules an earlier run checked are skipped (the ~110 s
# BeaconState closure is paid once). A cache TRUSTS earlier results: this is NEVER a gate, never used for a
# stamp; pins are not verified in this mode and every line of output says so. Measured (port sources, e2e
# FuluBeaconState witness): 190 s first run, 9 s when rerun with the cache warm; a different file sharing the
# closure gains little (BeaconBlock witness 75 s -> 68 s). The dev toolchain is the RIGID Bend: it only
# accepts the port branch's sources (agent/bend2034-depth), not the 2.0.28-era tree on main.
# Nothing heavy runs on this machine: only git and rsync.
set -u
HOST=${ITER_HOST:-root@build-server.example}
DIR=${ITER_DIR:-/srv/ssz-optimization/agents/iter-$(id -un)}
if [ "${1:-}" = --remote ]; then
  # ---- on the server: iter.sh --remote <jobs> <regen 0|1> <force> <cache 0|1> <files...>
  shift; J=$1; REGEN=$2; FORCE=$3; CACHE=$4; shift 4
  cd "$DIR" || exit 2
  exec 9> .iter.lock; flock -n 9 || { echo "iter.sh: another iter.sh run uses $DIR"; exit 2; }
  t0=$(date +%s)
  files=("$@")
  if [ "$REGEN" = 1 ]; then
    python3 codegen/regenerate_all.py --touched -j 12 ${FORCE:+--force "$FORCE"} 2>&1 | grep -v '^CHANGED ' | sed 's/^/regen: /'
    [ "${PIPESTATUS[0]}" = 0 ] || { echo "iter.sh: regeneration failed"; exit 2; }
    [ -f build/regen_changed.txt ] && while read -r f; do files+=("$f"); done < build/regen_changed.txt
  fi
  # unique existing .bend files, not under tools/ or vendor/
  mapfile -t files < <(printf '%s\n' "${files[@]}" | grep '\.bend$' | grep -v '^\(tools\|vendor\)/' | sort -u | while read -r f; do [ -f "$f" ] && echo "$f"; done)
  echo "iter: ${#files[@]} file(s) to check ($(( $(date +%s) - t0 )) s so far)"
  [ ${#files[@]} = 0 ] && exit 0
  T=${BEND_TOOLCHAIN:-$(sed -n 's/^T=\${BEND_TOOLCHAIN:-\(.*\)}$/\1/p' tools/check.sh | head -1)}
  if [ "$CACHE" = 1 ]; then
    T=/srv/ssz-optimization/toolchain-dev-cache; export BEND_CACHE=/srv/ssz-optimization/agents/iter-cache-$(id -un)
    mkdir -p "$BEND_CACHE"; echo "iter: DEV MODULE CACHE ($BEND_CACHE): results are NOT a gate"
  else
    if grep -q -- '--lock' tools/verify_pins.py; then
      python3 tools/verify_pins.py --lock "${BEND_LOCK:-toolchain.lock.json}" --toolchain "$T" --lib "${BEND_LIB:-vendor/bendhub}" >&2 || { echo "iter.sh: toolchain does not match the lock"; exit 3; }
    else
      python3 tools/verify_pins.py --toolchain "$T" --lib "${BEND_LIB:-vendor/bendhub}" >&2 || { echo "iter.sh: toolchain does not match the lock"; exit 3; }
    fi
  fi
  export BEND_TOOLCHAIN=$T CHECK_PINS_VERIFIED=1 CHECK_TIMEOUT=${ITER_TIMEOUT:-900}
  rm -rf build/iter; mkdir -p build/iter
  one() {
    f=$1; lg=build/iter/$(echo "$f" | tr '/' '_').log
    tools/check.sh "$f" > "$lg" 2>&1; rc=$?
    ok=0; grep -Eqx 'All terms check\.|ALL PROOFS CHECK' "$lg" && [ $rc = 0 ] && ok=1
    s=$(grep '^CHECK_TIME' "$lg" | tail -1 | awk '{print $2}')
    if [ $ok = 1 ]; then printf 'PASS %6ss  %s\n' "${s:-?}" "$f"
    else
      printf 'FAIL %6ss  %s  (rc %s)  log %s/%s\n' "${s:-?}" "$f" "$rc" "$DIR" "$lg"
      loc=$(grep -m1 -A1 '^Location' "$lg" | tr '\n' ' ' | sed 's/  */ /g')
      [ -n "$loc" ] && echo "     $loc" || tail -n 4 "$lg" | sed 's/^/     /'
    fi
    [ $ok = 1 ]
  }
  export -f one; export DIR
  printf '%s\n' "${files[@]}" | xargs -P "$J" -I{} bash -c 'one "$@"' _ {} | tee build/iter/summary.txt
  fails=$(grep -c '^FAIL' build/iter/summary.txt)
  echo "iter: $(grep -c '^PASS' build/iter/summary.txt) pass, $fails fail in $(( $(date +%s) - t0 )) s$([ "$CACHE" = 1 ] && echo ' (DEV CACHE, NOT A GATE)')"
  [ "$fails" = 0 ]
  exit $?
fi

# ---- local: rsync, ask the server, pull the regenerated files back
GEN=; BASE=; J=4; REGEN=1; PULL=1; CACHE=0; FILES=()
while [ $# -gt 0 ]; do
  case $1 in
    --gen) GEN=$2; shift 2;;
    --base) BASE=$2; shift 2;;
    -j) J=$2; shift 2;;
    --no-regen) REGEN=0; shift;;
    --no-pull) PULL=0; shift;;
    --cache) CACHE=1; shift;;
    -h|--help) sed -n '2,32p' "$0"; exit 0;;
    *) FILES+=("$1"); shift;;
  esac
done
R=$(cd "$(dirname "$0")/.." && pwd); cd "$R" || exit 2
# .bend files that differ from the base (uncommitted and untracked; or everything since --base)
{ if [ -n "$BASE" ]; then git diff --name-only --diff-filter=d "$BASE"; else git diff --name-only --diff-filter=d HEAD; fi
  git ls-files -o --exclude-standard; } | grep '\.bend$' > "${TMPDIR:-/tmp}/iter_changed.$$" || true
CH=(); while IFS= read -r l; do [ -n "$l" ] && CH+=("$l"); done < "${TMPDIR:-/tmp}/iter_changed.$$"; rm -f "${TMPDIR:-/tmp}/iter_changed.$$"
ALL=(${FILES[@]+"${FILES[@]}"} ${CH[@]+"${CH[@]}"})
EX=(--exclude .git --exclude build --exclude node_modules --exclude __pycache__ --exclude .iter.lock)
ssh "$HOST" "mkdir -p '$DIR'" || exit 2
t0=$(date +%s)
rsync -a --delete "${EX[@]}" ./ "$HOST:$DIR/" || exit 2
echo "iter: synced to $HOST:$DIR in $(( $(date +%s) - t0 )) s; local changes: ${#CH[@]} .bend file(s)"
ssh "$HOST" "cd '$DIR' && ITER_DIR='$DIR' ${BEND_TOOLCHAIN:+BEND_TOOLCHAIN='$BEND_TOOLCHAIN'} nice -n 10 bash tools/iter.sh --remote $J $REGEN '$GEN' $CACHE $(printf "'%s' " ${ALL[@]+"${ALL[@]}"})"
rc=$?
if [ "$PULL" = 1 ] && [ "$REGEN" = 1 ]; then
  PL=$(ssh "$HOST" "cat '$DIR/build/regen_changed.txt' 2>/dev/null")
  if [ -n "$PL" ]; then echo "$PL" | rsync -a --files-from=- "$HOST:$DIR/" ./ && echo "iter: $(echo "$PL" | wc -l | tr -d ' ') regenerated file(s) pulled back"; fi
fi
exit $rc
