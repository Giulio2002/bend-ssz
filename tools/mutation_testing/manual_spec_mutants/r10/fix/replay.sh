#!/bin/bash
# replay.sh <tree> <patch> <outlog> <law files...>: apply the patch on a hard-linked copy, check each law file (pinned settings)
set -u
T=$1; P=$2; L=$(readlink -f $3); shift 3
W=/srv/ssz-optimization/agents/fixH-r10/mut/$(basename $(dirname $P))_$(basename $P .patch)
rm -rf "$W"; mkdir -p $(dirname $W); cp -al "$T" "$W"
cd "$W" && patch -s -p1 --no-backup-if-mismatch < "$P" || { echo "PATCH_FAIL $P" > "$L"; rm -rf "$W"; exit 0; }
: > "$L"
for f in "$@"; do
  CHECK_TIMEOUT=300 nice -n 19 tools/check.sh "$f" > "$L.$(basename $f).log" 2>&1
  if grep -q 'ALL PROOFS CHECK' "$L.$(basename $f).log"; then r=PASS; elif grep -q 'stack overflowed' "$L.$(basename $f).log"; then r=STACK; elif grep -q 'SOME PROOFS FAIL\|Error' "$L.$(basename $f).log"; then r=FAIL; else r=OTHER; fi
  echo "$r $f $(grep -o 'CHECK_TIME [0-9.]*' "$L.$(basename $f).log")" >> "$L"
done
cd / && rm -rf "$W"
