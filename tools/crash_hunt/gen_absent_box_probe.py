#!/usr/bin/env python3
"""Round-3 crash hunt (docs/CRASH_HUNT.md CH-12): absent-box probe generator. For every named type with a `_serialize` and a boxed field
(`O.Boxed<..>`), writes Bend programs that serialize the default of the type with that one field set to the empty box (`O.BNone`) and
print `NAME.field ok=<0|1>`. The documented contract: an absent box is not valid, `_serialize` refuses it (ok=0). Run on the server.

    python3 tools/crash_hunt/gen_absent_box_probe.py --repo . --out DIR [--groups 6]
Writes DIR/ab<k>.bend. Every line of every program must read ok=0.
"""
import argparse
import os
import re
import sys


def split_top(s):
    out, depth, cur = [], 0, ''
    for ch in s:
        if ch in '<({':
            depth += 1
        elif ch in '>)}':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def boxed_fields(defs):
    """[(field, runtime type of the box)] of the record type of a name's def file"""
    found = []
    for m in re.finditer(r'^type (\w+) is Type:\n  (\w+)\{(.*)\}\s*$', defs, re.M):
        for f in split_top(m.group(3)):
            name, _, ty = f.partition(':')
            ty = ty.strip()
            if ty.startswith('O.Boxed<'):
                found.append((m.group(2), name.strip(), ty))
    return found


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', default='.')
    ap.add_argument('--out', required=True)
    ap.add_argument('--groups', type=int, default=6)
    a = ap.parse_args()
    T = os.path.join(a.repo, 'types')
    items = []
    for f in sorted(os.listdir(T)):
        if not f.endswith('_encode_ssz_generated.bend'):
            continue
        n = f[:-len('_encode_ssz_generated.bend')]
        enc = open(os.path.join(T, f)).read()
        dp = os.path.join(T, n + '_def_generated.bend')
        if '_serialize(' not in enc or not os.path.exists(dp):
            continue
        defs = open(dp).read()
        m = re.search(r'^def (\w+)_serialize\((\+?)o: ([^)]*)\) -> (.*)$', enc, re.M)
        if not m:
            continue
        sname, ret = m.group(1), m.group(4)
        pair = ret.strip().rstrip(':') != 'O.Encoded' and not ret.strip().startswith('O.Encoded')
        d = re.search(r'^def (\w+)_default\(\)', defs, re.M)
        if not d:
            continue
        for ctor, field, ty in boxed_fields(defs):
            setter = re.search(r'^def (\w+_set_%s)\(' % re.escape(field), defs, re.M)
            if not setter:
                continue
            top = sname if re.search(r'^def %s_default\(\)' % re.escape(sname), defs, re.M) else d.group(1)
            if ctor == top:
                expr = '%s_d.%s(%s_d.%s_default(), O.BNone{})' % (n, setter.group(1), n, top)
            else:
                # a grouped container: the record of the groups, the group of the field with the box absent, the others default
                rec = re.search(r'^  %s\{(g\d+: .*)\}\s*$' % re.escape(top), defs, re.M)
                if not rec:
                    continue
                parts = []
                for g in split_top(rec.group(1)):
                    gt = g.partition(':')[2].strip()
                    if gt == ctor:
                        parts.append('%s_d.%s(%s_d.%s_default(), O.BNone{})' % (n, setter.group(1), n, gt))
                    else:
                        parts.append('%s_d.%s_default()' % (n, gt))
                expr = '%s_d.%s{%s}' % (n, top, ', '.join(parts))
            items.append((n, sname, pair, expr, field, m.group(3)))
    os.makedirs(a.out, exist_ok=True)
    per = (len(items) + a.groups - 1) // a.groups
    for g in range(a.groups):
        part = items[g * per:(g + 1) * per]
        mods = sorted({i[0] for i in part})
        pre = os.path.relpath(os.path.abspath(a.repo), os.path.abspath(a.out)) + '/'
        L = ['import Base', 'import %ssrc/buffer.bend as B' % pre, 'import %ssrc/obj.bend as O' % pre]
        for n in mods:
            L.append('import %stypes/%s_def_generated.bend as %s_d' % (pre, n, n))
            L.append('import %stypes/%s_encode_ssz_generated.bend as %s_e' % (pre, n, n))
        L.append('''
def line(label: String, e: O.Encoded) -> String:
  match e:
    case O.Encoded{ok, b}: label ++ " ok=" ++ O.pick_str(ok)
''')
        for k, (n, s, pair, expr, field, st) in enumerate(part):
            call = '%s_e.%s_serialize(%s)' % (n, s, expr)
            if pair:
                L.append('def one%d(pair: %s & O.Encoded) -> String:\n  (o, e) = pair\n  line("%s.%s", e)\n' % (k, st, n, field))
                L.append('def s%d() -> String: one%d(%s)\n' % (k, k, call))
            else:
                L.append('def s%d() -> String: line("%s.%s", %s)\n' % (k, n, field, call))
        L.append('def main() -> IO(Unit):\n  do IO<Unit>:')
        for k in range(len(part)):
            L.append('    IO.print(s%d())' % k)
        L.append('    IO.print("DONE")')
        open(os.path.join(a.out, 'ab%d.bend' % g), 'w').write('\n'.join(L) + '\n')
    print(len(items), 'name.field cases', file=sys.stderr)


main()
