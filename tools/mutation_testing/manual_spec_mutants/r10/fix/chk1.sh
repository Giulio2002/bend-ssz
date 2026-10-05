#!/bin/bash
# chk1.sh <file>: check one file, print "status seconds file"
f=$1; L=/srv/ssz-optimization/agents/fixH-r10/logs/c/$(basename $f).log
CHECK_PINS_VERIFIED=1 CHECK_TIMEOUT=${TMO:-300} nice -n 19 tools/check.sh "$f" > $L 2>&1
if grep -q 'ALL PROOFS CHECK' $L; then r=PASS; elif grep -q 'stack overflowed' $L; then r=STACK; else r=FAIL; fi
echo "$r $(grep -o 'CHECK_TIME [0-9.]*' $L | cut -d' ' -f2) $f"
