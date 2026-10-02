#!/bin/bash
# tools/spec_audit/selftest.sh: show that constants.py detects a transcription error. Copies spec/, codegen/, schemas/,
# types/, proofs/obj/ to a scratch dir, applies one single-number mutation per round, and requires a MISMATCH each time.
# Usage (on the server, from the repo root): tools/spec_audit/selftest.sh /path/to/consensus-specs
set -u
CS=$(cd "$1" && pwd); R=$(pwd); T=$(mktemp -d /tmp/specaudit-selftest.XXXXXX)
for d in spec codegen schemas types proofs upstream.lock.json; do cp -r "$R/$d" "$T/" ; done
mkdir -p "$T/tools"; cp -r "$R/tools/spec_audit" "$T/tools/"
run() { (cd "$T" && python3 tools/spec_audit/constants.py --repo . --cs "$CS" --out "$T/out" | grep -c '^MISMATCH'); }
echo "baseline mismatches: $(run)"
mut() { # file sed-expression description
  cp "$T/$1" "$T/$1.orig"; sed -i "$2" "$T/$1"
  if cmp -s "$T/$1" "$T/$1.orig"; then echo "NOT APPLIED: $3"; else echo "$3: mismatches $(run)"; fi
  mv "$T/$1.orig" "$T/$1"
}
mut spec/fulu_schemas.bend 's/T.BitVector{512n}/T.BitVector{511n}/' 'SyncAggregate bitvector 512 -> 511 in spec/fulu_schemas.bend'
mut schemas/fulu_mainnet.json '0,/"length": 7,/s//"length": 8,/' 'FinalityBranch length 7 -> 8 in the JSON'
mut codegen/fulu.yaml 's/SLOTS_PER_HISTORICAL_ROOT: 8192/SLOTS_PER_HISTORICAL_ROOT: 4096/' 'SLOTS_PER_HISTORICAL_ROOT in codegen/fulu.yaml'
mut spec/layout.bend 's/case T.Variable{xs}: 4n/case T.Variable{xs}: 8n/' 'BYTES_PER_LENGTH_OFFSET slot 4 -> 8 in spec/layout.bend'
mut spec/type_legality.bend 's/U32.is_lt(head, 128)/U32.is_lt(head, 256)/' 'compatible-union selector bound 128 -> 256'
mut spec/progressive.bend 's/2n+depth, Tree.drop/1n+depth, Tree.drop/' 'progressive growth factor 4 -> 2'
mut types/byte_alias.bend 's/case Cell{}: Nat.mul(2n, 1024n)/case Cell{}: Nat.mul(3n, 1024n)/' 'Cell size'
rm -rf "$T"
