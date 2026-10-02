#!/usr/bin/env python3
"""cones.py TREE OUT.json: reverse import index. For every facade proof file (proofs/api/*_proof_generated.bend) its import cone
(files of types/ and src/ and proofs/obj only), written as {file: [facade, ...]} plus {facade: cone size}. Run on the server."""
import json, os, re, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from runner import cone
tree, out = sys.argv[1:3]
rev, size = {}, {}
memo = {}
for f in sorted(os.listdir(os.path.join(tree, 'proofs/api'))):
    if not f.endswith('_proof_generated.bend'):
        continue
    rel = 'proofs/api/' + f
    c = cone(tree, rel)
    size[rel] = len(c)
    for x in c:
        if x.startswith(('types/', 'src/')):
            rev.setdefault(x, []).append(rel)
json.dump({'rev': rev, 'size': size}, open(out, 'w'))
print(len(size), len(rev))
