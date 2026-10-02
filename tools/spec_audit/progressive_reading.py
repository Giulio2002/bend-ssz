#!/usr/bin/env python3
"""tools/spec_audit/progressive_reading.py: for the generic progressive containers, compare three roots of the same value: the
slot-placed reading (ssz_ref, EIP-7495), the literal prose reading (one chunk per field, no zero chunks for inactive slots) and
remerkleable. Run with the python 3.12 venv (remerkleable).
    /tmp/sa312/bin/python tools/spec_audit/progressive_reading.py ../cs
"""
import os, random, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ssz_ref as S
from constants import ref_generic
from rk_oracle import rk
gen = ref_generic(sys.argv[1])
rng = random.Random(3)
for name in sorted(n for n in gen if n.startswith('Progressive') and gen[n][0][0] == 'progcontainer'):
    t = gen[name][0]
    v = S.random_value(t, rng, 2)
    s = S.serialize(t, v)
    slots, prose = S.hash_tree_root(t, v), S.hash_tree_root_prose_progressive_container(t, v)
    r = rk(t, name).decode_bytes(s).hash_tree_root()
    print('%-44s active=%s slots==remerkleable %s  prose==remerkleable %s' % (name, ''.join('1' if b else '0' for b in t[2]), slots == r, prose == r))
