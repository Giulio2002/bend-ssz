#!/bin/bash
# tools/check_all.sh [--jobs N] [--list FILE] [--out DIR]: check every .bend file outside tools/
# and vendor/ (or the files listed in FILE) with tools/check.sh, N at a time (default 10).
# Writes DIR/<file>.log per file and DIR/summary.tsv (file, exit, ok, seconds, peak MB); prints
# the failures and the slowest files; exits nonzero if any file fails. Run from the repository root.
set -u
J=10; LIST=""; OUT=build/check_all
while [ $# -gt 0 ]; do
  case $1 in
    --jobs) J=$2; shift 2;;
    --list) LIST=$2; shift 2;;
    --out) OUT=$2; shift 2;;
    *) echo "usage: tools/check_all.sh [--jobs N] [--list FILE] [--out DIR]" >&2; exit 2;;
  esac
done
mkdir -p "$OUT"; : > "$OUT/summary.tsv"
if [ -n "$LIST" ]; then files=$(cat "$LIST"); else files=$(git ls-files '*.bend' | grep -v '^tools/\|^vendor/'); fi
one() {
  f=$1; out=$2
  lg=$out/$(echo "$f" | tr / _).log
  tools/check.sh "$f" > "$lg" 2>&1; rc=$?
  ok=$(grep -c 'All terms check' "$lg")
  tl=$(grep '^CHECK_TIME' "$lg" | tail -n 1)
  s=$(echo "$tl" | awk '{print $2}'); kb=$(echo "$tl" | awk '{print $3}')
  printf '%s\t%s\t%s\t%s\t%s\n' "$f" "$rc" "$ok" "${s:-0}" "$(( ${kb:-0} / 1024 ))" >> "$out/summary.tsv"
}
export -f one
echo "$files" | xargs -P "$J" -I{} bash -c 'one "$@"' _ {} "$OUT"
n=$(wc -l < "$OUT/summary.tsv")
bad=$(awk -F'\t' '$2 != 0 || $3 == 0' "$OUT/summary.tsv")
echo "checked $n files; slowest:"
sort -t$'\t' -k4 -g -r "$OUT/summary.tsv" | head -n 10 | awk -F'\t' '{printf "  %7.1f s %6d MB  %s\n", $4, $5, $1}'
if [ -n "$bad" ]; then echo "FAILED:"; echo "$bad" | cut -f1,2 | sed 's/^/  /'; exit 1; fi
echo "all files check"
