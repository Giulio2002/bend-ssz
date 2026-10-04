#!/usr/bin/env python3
"""Crash hunt round 6 (d): mutation drivers for the 131 GENERIC names (the generator emits them for the Fulu names only).

Run ONLY in a scratch copy of the tree (it rewrites the generated runtime there, never commit its output):

    cd SCRATCH && python3 tools/crash_hunt/r6/gen_generic_fuzz.py

It runs codegen/impl/typed_object_runtime.py with two changes: the generic runtime gets its `<Name>_fuzz` entry points (the same
emit_fuzz as the Fulu names: field writes, element writes and appends through the public setters), and the generic names get
mutation groups types/generic_obj_f<k>.bend (4 names each) plus their table types/generic_fuzz_ops.json. The setters and appenders
themselves are the generated ones, unchanged; only the dispatch is added.
"""
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../..'))
sys.path.insert(0, ROOT)
os.chdir(ROOT)
from codegen.impl import typed_object_runtime as T  # noqa: E402

_emit_all = T.emit_all


def emit_all(g, names, title=None, with_fuzz=True):
    return _emit_all(g, names, title=title, with_fuzz=True)


T.emit_all = emit_all
_generic = T.generic_outputs


def generic_outputs():
    out = _generic()
    text, g, names, _p = T.SPLIT_CTX[-1]
    order = list(names)
    ftable = {}
    for k in range(0, len(order), T.FUZZ_GROUP):
        gn = order[k:k + T.FUZZ_GROUP]
        j = k // T.FUZZ_GROUP
        ns = [(n, order.index(n)) for n in gn]
        out[T.ROOT / f'types/generic_obj_f{j}.bend'] = T.emit_group(g, names, ns, j, with_fuzz=True, prefix='f', module='generic_obj')
        for n, i in ns:
            ftable[n] = {'program': j, 'index': i, 'ops': g.fuzz_ops[n]}
    out[T.ROOT / 'types/generic_fuzz_ops.json'] = json.dumps(ftable, indent=1) + '\n'
    return out


T.generic_outputs = generic_outputs
T.main()
