"""Generate proofs/obj/prep_setters.bend: every field setter of the Type-kind
containers whose representation invariant `rep_<X>` is in root_types.bend
keeps that invariant.

`rep_<X>(o, s)` (root_types.bend) quantifies the container's Data-kind fields
(`DK.Ex(F, x_i => ...)`), states that o is the record of them and of its
Type-kind fields (`o == T.X{..}`), and lists the Type-kind fields'
invariants. For the setter `T.X_set_<f>(o, v)` of field i, the law is

    rep_X(o, s)  [and rep_F(v, s_i) when field i carries an invariant]
      ->  rep_X(T.X_set_<f>(o, v), s)

The proof rewrites o into its record, lets the setter reduce, and returns the
same witnesses and invariants with field i replaced by v. So the setter
changes field i only (the other components are the old ones, unchanged).

    python3 codegen/rep_laws.py            # write the file
    python3 codegen/rep_laws.py --check    # fail if it is stale
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'codegen'))
import schema as SC  # noqa: E402
import runtime_refs as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports

RT_PATH = ROOT / 'proofs/obj/root_types.bend'
# BeaconState's rep (and its projections) are in root_state.bend, imported as ST
ST_PATH = ROOT / 'proofs/obj/root_state.bend'
OUT = ROOT / 'proofs/obj/prep_setters.bend'


def split_top(s):
    """Split on top-level commas (outside (), {}, <>)."""
    out, depth, cur = [], 0, ''
    for ch in s:
        if ch in '({<':
            depth += 1
        elif ch in ')}>':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def strip_call(s, head):
    assert s.startswith(head + '(') and s.endswith(')'), (head, s[:80])
    return s[len(head) + 1:-1]


def parse_rep(name, body):
    exs = []
    rest = body
    while rest.startswith('DK.Ex('):
        m = re.match(r'DK\.Ex\(([\w.<>]+), (x(\d+)) => ', rest)
        exs.append((m.group(1), m.group(2), int(m.group(3))))
        rest = rest[m.end():]
        assert rest.endswith(')')
        rest = rest[:-1]
    a, b = split_top(strip_call(rest, 'DK.P2'))
    m = re.fullmatch(r'\{o == T\.' + name + r'\{(.*)\} : T\.' + name + r'\}', a)
    args = m.group(1)
    comps = []

    def walk(t):
        if t.startswith('DK.P2('):
            x, y = split_top(strip_call(t, 'DK.P2'))
            walk(x)
            walk(y)
        else:
            m2 = re.fullmatch(r'([\w.]+)\(pj_' + name + r'_(\d+)\(o\), (.*)\)', t)
            if m2:
                comps.append((m2.group(1), int(m2.group(2)), m2.group(3)))
            else:   # an invariant of a Data-kind field's witness x<i> (BeaconState's rp_bv4(x17))
                m3 = re.fullmatch(r'([\w.]+)\(x(\d+)\)', t)
                comps.append((m3.group(1), int(m3.group(2)), None))
    walk(b)
    return exs, args, comps


def qual(n, mod='RT'):
    return n if '.' in n else mod + '.' + n


RUNTIME = ['fulu']   # the runtime whose setters law() reads (build_generic switches it)


def type_fields(types, x):
    """a record type's field names in order, its groups (x_g<k>) expanded"""
    m = re.search(r'^type %s is \w+:\n  %s\{(.*)\}$' % (x, x), types, re.M)
    out = []
    for fd in split_top(m.group(1)):
        n, t = [a.strip() for a in fd.split(':', 1)]
        out += type_fields(types, t) if re.fullmatch(r'%s_g\d+' % x, t) else [n]
    return out


def setters(name, nfields):
    types = RR.mono_text(RUNTIME[0])
    if RUNTIME[0] == 'fulu':
        fields = [f for f, _ in SC.load(ROOT / 'codegen/fulu.yaml')[name].fields]
    else:
        fields = type_fields(types, name)
    assert len(fields) == nfields, (name, fields)
    out = []
    for i, f in enumerate(fields):
        m = re.search(rf'^def {name}_set_{f}\(o: {name}, \+?v: ([\w.<>]+)\) -> {name}:', types, re.M)
        if not m:
            # a range-checked setter (-> X & Bool, X_put_f(guard, o, v)): the law is about the write it
            # performs when the guard holds, X_set_f_go (e2e/<Name>_e2e_set_generated.bend composes the two)
            m = re.search(rf'^def {name}_set_{f}_go\(o: {name}, \+?v: ([\w.<>]+)\) -> {name}:', types, re.M)
            if RUNTIME[0] == 'fulu' or not m:
                raise SystemExit(f'{name}: no setter for field {f}')
            f = f + '_go'
        vt = re.sub(r'(?<![.\w])([A-Za-z]\w*)(?![.\w])',
                    lambda q: q.group(1) if q.group(1) in ('U32', 'Bool', 'Nat') else 'T.' + q.group(1), m.group(1))
        out.append((i, f, vt))
    return out


def law(name, exs, args, comps, mod='RT'):
    L = []
    w = L.append
    ex_idx = {i: (t, x) for t, x, i in exs}
    comp_idx = {i: (c, sch) for c, i, sch in comps}
    all_idx = sorted(set(ex_idx) | {i for _, i, _ in comps} | {int(k) for k in re.findall(r'pj_' + name + r'_(\d+)\(o\)', args)})
    qargs = re.sub(r'\bpj_', mod + '.pj_', args)
    for i, f, vt in setters(name, max(all_idx) + 1):
        data = i in ex_idx
        hyp = comp_idx.get(i)
        vq = '+v' if data else '-v'
        w(f'law {name}_set_{f}_rep:')
        w(f'  for -o: T.{name}')
        w('  for +s: S.Schema')
        w(f'  for {vq}: {vt}')
        w(f'  for +r: {mod}.rep_{name}(o, s)')
        if hyp:
            w(f'  for +rv: {qual(hyp[0], mod)}(v{"" if hyp[1] is None else ", " + hyp[1]})')
        w(f'  {mod}.rep_{name}(T.{name}_set_{f}(o, v), s)')
        w(f'def {name}_set_{f}_rep(o, s, v, r{", rv" if hyp else ""}):')
        prev = 'r'
        for k, (t, x, j) in enumerate(exs):
            w(f'  (+{x}, e{k}) = {prev}')
            prev = f'e{k}'
        qs = [f'q{j}' for _, j, _ in comps]
        if len(comps) == 1:
            w(f'  (+eo, +{qs[0]}) = {prev}')
        else:
            w(f'  (+eo, c0) = {prev}')
            for k in range(len(comps) - 1):
                nxt = f'+{qs[k + 1]}' if k == len(comps) - 2 else f'c{k + 1}'
                w(f'  (+{qs[k]}, {nxt}) = c{k}')
        w(f'  %Equal.sym(T.{name}, o, T.{name}{{{qargs}}}, eo) : {mod}.rep_{name}(T.{name}_set_{f}(_, v), s)')
        reps = ['rv' if j == i else f'q{j}' for _, j, _ in comps]
        tup = reps[-1]
        for rr in reversed(reps[:-1]):
            tup = f'({rr}, {tup})'
        tup = f'({{==}}, {tup})'
        for t, x, j in reversed(exs):
            tup = f'({"v" if j == i else x}, {tup})'
        w(f'  {tup}')
        w('')
    return L


def build():
    rt = RR.unwire(RT_PATH.read_text())   # the runtime's symbols as T.<sym> (root_types imports the split files)
    imports = [l for l in rt.split('\n') if l.startswith('import')]
    imports = [l for l in imports if not l.endswith(' as RT')] + ['import ./root_types.bend as RT']
    head = imports + ['',
                      '# GENERATED by codegen/rep_laws.py. Do not edit.',
                      '# Every field setter of the Type-kind containers keeps their representation',
                      '# invariant rep_<X> (root_types.bend), the hypothesis of their root laws: from',
                      '# rep_X(o, s) and, for a field with its own invariant, that invariant of the new',
                      '# value, rep_X(set_f(o, v), s) holds with field f replaced and the rest unchanged.', '']
    body, names = [], []
    st = RR.unwire(ST_PATH.read_text())
    have = {l.split(' as ')[1] for l in head if l.startswith('import ') and ' as ' in l}
    for l in st.split('\n'):   # root_state's own imports (its types), and root_state itself as ST
        if l.startswith('import ') and ' as ' in l and not l.endswith((' as RT', ' as ST', ' as LV')) and l.split(' as ')[1] not in have:
            head.insert(1, l)
            have.add(l.split(' as ')[1])
    head.insert(1, 'import ./root_state.bend as ST')
    for text, mod in ((rt, 'RT'), (st, 'ST')):
        for m in re.finditer(r'^def rep_(\w+)\(o: T\.(\w+), \+s: S\.Schema\) -> Data:\n  (.*)$', text, re.M):
            name, ty, b = m.groups()
            if name != ty or (name.startswith('l') and name[1].isdigit()):
                continue
            exs, args, comps = parse_rep(name, b)
            body.extend(law(name, exs, args, comps, mod))
            names.append(name)
    return '\n'.join(head + body) + '\n', names


# the generic containers' reps: one output per module, since both define rep_VarTestStruct
GENERIC = [('root_gtypes', 'prep_setters_g1'), ('root_gtypes2', 'prep_setters_g2')]


def build_generic(mod):
    src = RR.unwire((ROOT / f'proofs/obj/{mod}.bend').read_text())
    imports = [l for l in src.split('\n') if l.startswith('import') and not l.endswith(' as RT')]
    head = imports + [f'import ./{mod}.bend as RT', '',
                      '# GENERATED by codegen/rep_laws.py. Do not edit.',
                      f'# Every plain field setter of the generic containers whose rep_<X> is in {mod}.bend keeps it:',
                      '# rep_X(o, s) [and the new value\'s own invariant] -> rep_X(set_f(o, v), s). The range-checked',
                      '# setters (-> X & Bool) are covered in e2e/<Name>_e2e_set_generated.bend.', '']
    body, names = [], []
    RUNTIME[0] = 'generic'
    try:
        for m in re.finditer(r'^def rep_(\w+)\(o: T\.(\w+), \+s: S\.Schema\) -> Data:\n  (.*)$', src, re.M):
            name, ty, b = m.groups()
            if name != ty:
                continue
            exs, args, comps = parse_rep(name, b)
            body.extend(law(name, exs, args, comps, 'RT'))
            names.append(name)
    finally:
        RUNTIME[0] = 'fulu'
    return '\n'.join(head + body) + '\n', names


def main():
    text, names = build()
    outs = {OUT: RR.rewire(text)}
    for mod, out in GENERIC:
        t, ns = build_generic(mod)
        outs[ROOT / f'proofs/obj/{out}.bend'] = RR.rewire(t)
        names += ns
    if '--check' in sys.argv:
        stale = [str(p) for p, t in outs.items() if not p.exists() or p.read_text() != t]
        if stale:
            print(f'stale: {", ".join(stale)}; run codegen/rep_laws.py')
            return 1
        print(f'setter rep laws are current ({len(names)} containers)')
        return 0
    for p, t in outs.items():
        if not p.exists() or p.read_text() != t:
            p.write_text(t)
    print(f'{len(names)} containers: {" ".join(names)}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
