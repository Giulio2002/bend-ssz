#!/bin/bash
# rp1.sh "<family/NN> <law files...>": replay one fault against the new laws (C/ V/ A/ = proofs/slop/constants|validity|alignment)
cd /srv/ssz-optimization/agents/fixH-r10
set -- $1
id=$1; shift
fs=()
for x in "$@"; do d=${x%%/*}; n=${x#*/}; case $d in C) d=constants;; V) d=validity;; A) d=alignment;; esac; fs+=("proofs/slop/$d/${n}_generated.bend"); done
./replay.sh $PWD/tree $PWD/tree/tools/mutation_testing/manual_spec_mutants/patches/$id.patch $PWD/rp1/${id//\//_} "${fs[@]}"
