#!/bin/bash
# tools/check_fast.sh [--jobs N] [--target S] [--out DIR] [--files LIST]: check every .bend file
# outside tools/ and vendor/ (or those in LIST, with their imports) through umbrellas: files that
# only import a group of root files, so one Bend run checks each module of the group's closure once
# instead of once per importing file (tools/umbrellas.py explains the soundness argument). Same
# pinned checker and cgroup limits as tools/check.sh, but each umbrella gets a larger heap:
# UMB_MEMMAX (default 16G), UMB_RAM (JSC forceRAMSize, default 12e9; the 8e9 of single files
# makes a big umbrella collect constantly), UMB_TIMEOUT (default 1200 s). Writes DIR/<n>.log,
# DIR/summary.tsv (umbrella, exit, ok, seconds, peak MB, roots) and, for each failed umbrella,
# DIR/<n>.list, its roots: `tools/check_all.sh --list DIR/<n>.list` checks them one by one.
# Exits nonzero if any umbrella fails. Run from the repository root.
set -u
J=20; T=120; OUT=build/check_fast; FILES=""
while [ $# -gt 0 ]; do
  case $1 in
    --jobs) J=$2; shift 2;;
    --target) T=$2; shift 2;;
    --out) OUT=$2; shift 2;;
    --files) FILES=$2; shift 2;;
    *) echo "usage: tools/check_fast.sh [--jobs N] [--target S] [--out DIR] [--files LIST]" >&2; exit 2;;
  esac
done
t0=$(date +%s)
rm -rf "$OUT"; mkdir -p "$OUT"; : > "$OUT/summary.tsv"
python3 tools/umbrellas.py --target "$T" --out "$OUT/umb" ${FILES:+--files "$FILES"} || exit 2
one() {
  u=$1; out=$2
  lg=$out/${u%.bend}.log
  CHECK_MEMMAX=${UMB_MEMMAX:-16G} CHECK_TIMEOUT=${UMB_TIMEOUT:-1200} \
    BUN_JSC_forceRAMSize=${UMB_RAM:-12000000000} tools/check.sh "$out/umb/$u" > "$lg" 2>&1; rc=$?
  ok=$(grep -c 'All terms check' "$lg")
  tl=$(grep '^CHECK_TIME' "$lg" | tail -n 1)
  s=$(echo "$tl" | awk '{print $2}'); kb=$(echo "$tl" | awk '{print $3}')
  roots=$(awk -F'\t' -v u="$u" '$1 == u {print $4}' "$out/umb/plan.tsv")
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$u" "$rc" "$ok" "${s:-0}" "$(( ${kb:-0} / 1024 ))" "$roots" >> "$out/summary.tsv"
  if [ "$rc" != 0 ] || [ "$ok" = 0 ]; then echo "$roots" | tr ' ' '\n' > "$out/${u%.bend}.list"; fi
}
export -f one
cut -f1 "$OUT/umb/plan.tsv" | xargs -P "$J" -I{} bash -c 'one "$@"' _ {} "$OUT"
n=$(wc -l < "$OUT/summary.tsv")
echo "checked $n umbrellas in $(( $(date +%s) - t0 )) s; slowest:"
sort -t$'\t' -k4 -g -r "$OUT/summary.tsv" | head -n 5 | awk -F'\t' '{printf "  %7.1f s %6d MB  %s  %.60s\n", $4, $5, $1, $6}'
bad=$(awk -F'\t' '$2 != 0 || $3 == 0 {print $1}' "$OUT/summary.tsv")
if [ -n "$bad" ]; then
  echo "FAILED (the log names the definition; DIR/<n>.list holds the umbrella's roots):"
  for u in $bad; do echo "  $OUT/${u%.bend}.log"; grep -m1 -A1 '^Location' "$OUT/${u%.bend}.log" | sed 's/^/    /'; done
  exit 1
fi
echo "all files check"
