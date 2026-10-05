#!/usr/bin/env python3
"""The object API's coverage map and gate: for every Fulu name and every ssz_generic form,
each law of the object API, the proof file and law that prove it, and whether that file is
stock or big (checkq --big).

    python3 codegen/proofs/facades/object_api_coverage_gate.py [--check]

Derived from the proof files (proofs/obj/*.bend), not by hand: every top-level law / def is
parsed, its conclusion (and, for the spec relation, its hypotheses) is searched for the
object API entry points of a name X - T.X_decode, T.X_encode, T.X_ok, T.X_hash_tree_root,
T.X_serialize - and for Spec.X() under Decoding.decodes / Decoding.outside_image. A law
counts for (X, kind) when its name has the kind's form (LAW_FORMS) AND its conclusion has
the kind's shape (SHAPE); nothing is taken from a table of files.

The object API's laws (docs/LAW_API_MAP.md):
  root            T.X_hash_tree_root's digest is the spec root (RR.roots)
  ok_eval         the validator T.X_ok returns the check's Bool
  decode_accept   the decoder T.X_decode returns Some{object}
  decode_spec     the decoded buffer's bytes are the spec encoding of the object's value
  decode_unique   every spec value of those bytes is that value
  decode_reject   bytes the decoder refuses are outside the spec image
  decode_none     the decoder returns None (the check fails / another size)
  encode_eval     the encoder T.X_encode returns the object and the output buffer (its bytes)
  encode_spec     the encoder's bytes are the spec encoding of the object's value
  and the aligned-codec laws roundtrip, encoded_size, reject_short, reject_long, the
  buffer-tree / loader decode laws decode_tree, decode_input, and serialize_valid.

Writes
  proofs/gate/api_map.json           {name: {kind: [{file, law, big}]}} (every name, every kind)
  proofs/gate/MISSING.txt            every (name, law) with no proving law
  proofs/gate/g__<file>_generated.bend (a slop file: proofs/gate/slop/<group>/<file>_generated.bend)
      one module per proving file: for each name X and each law of that file proving
      (X, kind), a def <X>__<kind>__<law> whose statement is the proving law's statement
      (the object API entry point in its conclusion), discharged by applying the proving
      law. A module imports only its proving file, and each proving file has one module,
      so every proof file is checked once by the gate (Bend re-checks every import: a
      module per (name, file) re-checked root_names.bend 246 times); big_ when the file is.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import json
import os
import re
import sys
from codegen.impl import runtime_file_split as RR  # noqa: E402  the runtime split: the monoliths' text, the split files' imports

from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.core.repository_paths import ROOT, OBJ  # noqa: E402
OUT = ROOT / 'proofs/gate'

KINDS = ['root', 'ok_eval', 'decode_accept', 'decode_spec', 'decode_unique', 'decode_reject', 'decode_none',
         'encode_eval', 'encode_spec', 'roundtrip', 'encoded_size', 'reject_short', 'reject_long',
         'decode_tree', 'decode_input', 'serialize_valid', 'decode_offsets', 'decode_first_offset']
CORE = KINDS[:9]

# law-name forms per kind (<X> the name; bare names are the per-name modules' laws)
LAW_FORMS = {
    'root': [r'<X>_root_correct'],
    'ok_eval': [r'ok_eval', r'<X>_ok_eval', r'<X>_okf_len', r'<X>_ua_\w+'],
    'decode_accept': [r'decode_accept', r'<X>_spec_decode', r'<X>_spec_decode_[01]', r'<X>_arith_dec'],
    'decode_spec': [r'decode_spec', r'<X>_spec_decoded', r'<X>_spec_encode', r'<X>_(true|false)_spec_encode', r'<X>_spec_value'],
    'decode_unique': [r'decode_unique', r'<X>_spec_unique', r'<X>_spec_unique_[01]'],
    'decode_reject': [r'decode_reject', r'<X>_outside', r'<X>_spec_reject_outside', r'<X>_decode_reject'],
    'decode_none': [r'decode_none', r'<X>_spec_reject', r'<X>_spec_reject_(bool|pad)', r'<X>_spec_decode_reject'],
    'encode_eval': [r'encode_eval', r'<X>_spec_bytes', r'<X>_(true|false)_spec_bytes', r'<X>_arith_(pw[123]|put|putw)', r'<X>_encode_capsym', r'<X>_cmp_(all|unal|pwd)', r'<X>_cf_(flag|acc)'],
    'encode_spec': [r'encode_spec', r'<X>_spec_encode', r'<X>_(true|false)_spec_encode'],
    'roundtrip': [r'<X>(_[tf])?_roundtrip'],
    'encoded_size': [r'<X>(_[tf])?_encoded_size'],
    'reject_short': [r'<X>(_[tf])?_reject_short'],
    'reject_long': [r'<X>(_[tf])?_reject_long'],
    'decode_tree': [r'<X>_spec_decode(_[01]|_reject)?_tree'],
    'decode_input': [r'<X>_spec_input'],
    'serialize_valid': [r'<X>_serialize_valid', r'<X>_serialize_over', r'<X>_serialize_in', r'<X>_serialize_v(dom|in(_\d+)?|over|sym|flag|fields|reject_\w+|refuse_\w+|poison_\w+|bool_\w+|bits_\w+|coll_\w+|unit_\w+)', r'<X>_serialize_cap', r'<X>_serialize_capsym'],
    'decode_offsets': [r'<X>_decode_build', r'<X>_decode_fields', r'<X>_decode_v(?:read_u16_\d+|bits_clear_\d+|and_pair|sel_\w+|checked_\w+|lit_\w+)'],
    'decode_first_offset': [r'<X>_decode_first_offset'],
}


def SHAPE(kind, X, concl, hyps):
    """The conclusion's shape for (X, kind)."""
    dec = f'T.{X}_decode('
    enc = f'T.{X}_encode('
    # the name's schema: Spec.X() / GS.X() (generic_specs), or a variable s with s == that
    sv = re.search(rf'\{{s == \w+\.{X}\(\) : S\.Schema\}}', hyps) is not None
    spec = rf'(?:\w+\.{X}\(\){"|s" if sv else ""})'
    if kind == 'root':
        return 'RR.roots(' in concl and f'T.{X}_hash_tree_root(' in concl
    if kind == 'ok_eval':
        return (concl.startswith(f'{{T.{X}_ok(') or (X in VALIDATOR and concl.startswith(f'{{T.{VALIDATOR[X]}_ok('))
                or (X in VALIDATOR and concl.startswith(f'{{T.{VALIDATOR[X]}_ok_len(False'))
                or re.match(rf'\{{T\.{re.escape(X)}_(?:ok|rd)\d+\(', concl) is not None)
    if kind in ('decode_accept', 'decode_input', 'decode_tree'):
        return concl.startswith('{' + dec) and 'Some{' in concl
    if kind in ('decode_none', 'reject_short', 'reject_long'):
        return dec in concl and 'None{}' in concl
    if kind in ('decode_spec', 'encode_spec'):
        return re.match(rf'Decoding\.decodes\({spec}, ', concl) is not None
    if kind == 'decode_unique':
        return concl.startswith('{v == ') and re.search(rf'Decoding\.decodes\({spec}, ', hyps) is not None
    if kind == 'decode_reject':
        return re.match(rf'Decoding\.outside_image\({spec}, ', concl) is not None
    if kind == 'encode_eval':
        return (concl.startswith('{' + enc) or concl.startswith('{B.emit(' + enc) or re.match(r'\{\w+\.emitted\([^,]+, ' + re.escape(enc), concl) is not None
                or re.match(r'\{T\.\w+_(?:pw[123]|pwd|put)\(', concl) is not None
                or re.match(rf'\{{(?:Pair\.snd\([^\n]*)?T\.{re.escape(X)}_putk\(', concl) is not None)
    if kind == 'roundtrip':
        return concl.startswith('{' + dec + enc) and 'Some{' in concl
    if kind == 'encoded_size':
        return enc in concl or f'T.{X}_bx_size(' in concl
    if kind == 'serialize_valid':
        return concl.startswith(f'{{T.{X}_serialize(') or concl.startswith(f'{{Pair.snd(') and f', O.Encoded, T.{X}_serialize(' in concl or re.match(r'\{(?:Pair\.snd\([^,]*, Bool, )?(?:T\.\w+_(?:valid|pk_ok|bx_size|bx_valid)|O\.\w+)\(', concl) is not None or re.search(r'O\.(?:bits_above_zero|bits_nbytes|words_blit|bits_size|unit_ok)\(|T\.\w+_(?:append|set|get|len|len_of|bx_putk|putn|senc_go|senc_sized|senc_out|size)\(', concl) is not None
    if kind == 'decode_offsets':
        return (concl.startswith('{' + dec) and ('Some{' in concl or f'T.{X}_some(' in concl)) or re.search(r'O\.(?:rd_u16|bits_clear|and_pair)\(|T\.\w+_(?:ok|dchw|decode_checked|decode)\(', concl) is not None
    if kind == 'decode_first_offset':
        return concl.startswith(f'{{T.{X}_ok(')
    return False


def validators():
    """{name: the runtime prefix of its decoder's validator} (X_decode = X_built(size, P_ok(buf, 0, size)))"""
    out = {}
    for f in ('fulu', 'generic'):
        src = RR.mono_text(f)
        for m in re.finditer(r'^def (\w+)_decode_in\(buf: B\.Buf, \+size: U32\)[^\n]*\n  \w+\(size, (\w+)_ok\(buf, 0, size\)\)', src, re.M):
            out[m.group(1)] = m.group(2)
    return out


VALIDATOR = validators()


def universe():
    from codegen.core import fulu_schema_loader as schema
    from codegen.core import generic_form_schemas as generic
    fulu = list(schema.load(ROOT / 'codegen/fulu.yaml'))
    gen = [n for n, t, e in generic.inventory_all() if e is None]
    return fulu, gen


# ---- parsing ----------------------------------------------------------------------------------

def split_top(s, sep=','):
    out, cur, d = [], '', 0
    for c in s:
        if c in '([{<':
            d += 1
        elif c in ')]}>':
            d -= 1
        if c == sep and d == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += c
    if cur.strip():
        out.append(cur.strip())
    return out


def parse_sig(s):
    depth, k = 0, None
    for q, c in enumerate(s):
        if c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
            if depth == 0:
                k = q
                break
    if k is None:
        return None
    rest = s[k + 1:]
    mm = re.match(r'\s*->\s*', rest)
    if not mm:
        return (s[1:k], '') if rest.strip().startswith(':') else None
    r = rest[mm.end():]
    d = 0
    for q, c in enumerate(r):
        if c in '([{':
            d += 1
        elif c in ')]}':
            d -= 1
        elif c == ':' and d == 0 and (q + 1 == len(r) or r[q + 1] == ' '):
            return (s[1:k], r[:q].strip())
    return None


def blocks(text):
    """[(kind, name, params (list of 'p: T'), statement)] of the top-level laws and defs."""
    lines = text.split('\n')
    out, laws, i = [], set(), 0
    while i < len(lines):
        l = lines[i]
        m = re.match(r'law (\w+):', l)
        if m:
            j, body = i + 1, []
            while j < len(lines) and lines[j].startswith('  '):
                body.append(lines[j].strip())
                j += 1
            fors = [b[4:] for b in body if b.startswith('for ')]
            st = ' '.join(b for b in body if not b.startswith('for '))
            laws.add(m.group(1))
            out.append(('law', m.group(1), fors, st))
            i = j
            continue
        m = re.match(r'def (\w+)\(', l)
        if m:
            j, sig = i, l
            while True:
                r = parse_sig(sig[len('def ' + m.group(1)):])
                if r is not None or j - i > 80 or j + 1 >= len(lines):
                    break
                j += 1
                sig += ' ' + lines[j].strip()
            if m.group(1) not in laws:
                params, ret = r if r else ('', '')
                out.append(('def', m.group(1), split_top(params), ret))
            i = j + 1
            continue
        i += 1
    return out


def pname(p):
    return p.split(':')[0].strip().lstrip('+-@').strip()


# ---- the proving files -------------------------------------------------------------------------
# A proving file is named by its key: a bare file name for proofs/obj/<name>.bend, and `slop/<group>/<name>_generated.bend`
# (the path below proofs/) for the laws that exist because mutation testing found a gap. The scan reads proofs/obj first and then
# the slop modules, in the order of LAYOUT.GROUPS: the bridges and the facades read the first law of a kind, and the
# first proving import of an encode facade must stay the name's own spec/encx file, so the slop laws come last.

def proving_files():
    """Every proving file, as a path: proofs/obj first, then proofs/slop group by group (each sorted)."""
    files = sorted(OBJ.glob('*.bend'))
    for g in LAYOUT.GROUPS:
        files += sorted((LAYOUT.SLOP / g).glob('*.bend'), key=lambda q: LAYOUT.stem_of(q) + '.bend')     # the order of the names as the generators gave them, without the suffix
    return files


def file_key(f):
    return f.name if f.parent == OBJ else str(f.relative_to(LAYOUT.PROOFS))


def proof_path(key):
    return OBJ / key if '/' not in key else LAYOUT.PROOFS / key


def gate_path(key):
    """the gate module of a proving file: proofs/gate/g__<name>_generated.bend for a bare proofs/obj file, and for a slop file
    key `slop/<group>/<name>_generated.bend` the same folders under proofs/gate/"""
    if '/' in key:
        return OUT / key
    return OUT / f'g__{key[:-5]}_generated.bend'


def prv_import(key, here=None):
    """the import path of proving file `key` from a module in directory `here` (default: proofs/api and proofs/gate, the same depth)"""
    if "/" not in key:
        return f"../obj/{key}"
    return os.path.relpath(LAYOUT.PROOFS / key, here or OUT)


def below_proofs(key):
    """the path of proving file `key` below proofs/"""
    return f"obj/{key}" if "/" not in key else key


def proving_imports(key, src, here=None):
    """[(path, alias or None)] of the imports of proving file `key`, as a module of proofs/api or proofs/gate writes them: a bare
    file's `./x` is `../obj/x`; a slop file's relative imports are re-based on the directory `here` (default proofs/gate)."""
    out = []
    for l in src.split('\n'):
        m = re.match(r'import (\S+)( as (\w+))?$', l)
        if not m:
            continue
        path = m.group(1)
        if '/' not in key:
            if path.startswith('./'):
                path = '../obj/' + path[2:]
        elif path.startswith('.'):
            there = os.path.normpath(os.path.join(os.path.dirname(proof_path(key)), path))
            path = os.path.relpath(there, here or OUT)
        out.append((path, m.group(3)))
    return out


# ---- the map ----------------------------------------------------------------------------------

def scan():
    fulu, gen = universe()
    U = set(fulu) | set(gen)
    ent = {}      # (X, kind) -> [(file, law)]
    parsed = {}
    late = []
    api = re.compile(r'T\.(\w+?)_(decode|encode|ok|hash_tree_root|serialize|bx_size)\(')
    spc = re.compile(r'Decoding\.(?:decodes|outside_image)\(\w+\.(\w+)\(\)|\{s == \w+\.(\w+)\(\) : S\.Schema\}')
    for f in proving_files():
        key = file_key(f)
        bl = blocks(f.read_text())
        parsed[key] = bl
        for k, n, params, st in bl:
            # the runtime's symbols read as T.<sym> (a module imports the split files: RR.unwire)
            hyps = RR.unwire(' '.join(params))
            st = RR.unwire(st)
            xs = {m.group(1) for m in api.finditer(st)} | {m.group(1) or m.group(2) for m in spc.finditer(st + ' ' + hyps)}
            if n.endswith('_ok_eval'):
                xs.add(n[:-len('_ok_eval')])
            if n.endswith('_serialize_vsym'):     # codegen/proofs/slop/validity_checks.py: the statement names the validity pass
                xs.add(n[:-len('_serialize_vsym')])
            if n.endswith('_serialize_vflag'):    # codegen/proofs/slop/poison_flag.py: the statement names the writer's pk_ok
                xs.add(n[:-len('_serialize_vflag')])
            mv = re.fullmatch(r'(\w+)_serialize_v(?:fields|reject_\w+|refuse_\w+|poison_\w+|bool_\w+|bits_\w+|coll_\w+|unit_\w+)', n)    # container_field_validity / packed_boolean_validity / bit_padding_validity
            if mv:
                xs.add(mv.group(1))
            md = re.fullmatch(r'(\w+)_decode_v(?:read_u16_\d+|bits_clear_\d+|and_pair|sel_\w+|checked_\w+|lit_\w+)', n)    # codegen/proofs/slop/small_type_predicates.py
            if md:
                xs.add(md.group(1))
            ma = re.match(r'(\w+?)_(?:arith|cmp|okf|cf|ua)_', n)     # codegen/proofs/slop/word_positions.py: the writers' own names are not X's
            if ma:
                xs.add(ma.group(1))
            if n == 'ok_eval':      # a per-name module's validator law: the name is in the file name
                # (a readable name can hold '_': bitlist_33, proglist_bool; SHAPE then keeps only X's own)
                xs |= {X for X in U if f'_{X}_' in f'_{f.stem}_'}
            for X in xs & U:
                for kind in KINDS:
                    if any(re.fullmatch(pat.replace('<X>', re.escape(X)), n) for pat in LAW_FORMS[kind]) and SHAPE(kind, X, st, hyps):
                        ent.setdefault((X, kind), []).append((key, n))
            # codegen/proofs/slop/encoder_constants.py: proofs/slop/constants/<X>.bend holds <X>_mc_<tag> laws, one module
            # per name (the name is in the file name); the root wrapper's law belongs to the root facade, the others to
            # the encode facade (serialize_valid)
            per_name_laws = f.parent.name in ('constants', 'size') and f.parent.parent == LAYOUT.SLOP   # encoder_constants.py / write_start_and_sizes.py
            if per_name_laws and k == 'def' and LAYOUT.stem_of(f) in U:
                X = LAYOUT.stem_of(f)
                mc = re.fullmatch(re.escape(X) + r'_m[cs]_(\w+)', n)
                if mc:
                    late.append(((X, 'root' if mc.group(1) == 'root' else 'decode_input' if mc.group(1).startswith(('dec', 'build', 'arm')) else 'serialize_valid'), (key, n)))
            # codegen/proofs/slop/bit_padding_validity.py: <X>_vbits_nbytes (the bit count of a bit list) is a law of the ROOT facade
            # (hash_tree_root reads it); its twin <X>_serialize_vbits_nbytes goes to the encode facade by the name form
            nb = re.fullmatch(r'(\w+)_vbits_nbytes', n) if f.parent.name == 'validity' and f.parent.parent == LAYOUT.SLOP else None
            if nb and nb.group(1) in U and k == 'def':
                late.append(((nb.group(1), 'root'), (key, n)))
            # codegen/proofs/slop/tight_storage_root.py, cached_list_roots.py: <X>_vroot_<p>_<tag> pin the ROOT of X (storage independence, cached trees)
            vr = re.fullmatch(r'(\w+?)_vroot_\w+', n) if f.parent.name == 'validity' and f.parent.parent == LAYOUT.SLOP else None
            if vr and vr.group(1) in U and k == 'def':
                late.append(((vr.group(1), 'root'), (key, n)))
    for lkey, v in late:      # after every other law: the bridges read the first law of a kind
        ent.setdefault(lkey, []).append(v)
    return fulu, gen, ent, parsed


# ---- the gate modules -------------------------------------------------------------------------

def gate_module(xlaws, fname, parsed_file, src):
    """One module per proving file; xlaws: [(X, [(kind, law)])]."""
    here = gate_path(fname).parent
    fixed = [f'import {path}' + (f' as {alias}' if alias else '') for path, alias in proving_imports(fname, src, here)]
    local = {n for _, n, _, _ in parsed_file}
    L = fixed + [f'import {prv_import(fname, here)} as PRV', '',
                 '# GENERATED by object_api_coverage_gate (codegen). Do not edit.',
                 f'# The object API laws that proofs/{below_proofs(fname)} proves ({", ".join(X for X, _ in xlaws)}), each discharged by that law.', '']
    for X, kind, law in [(X, k, n) for X, laws in xlaws for k, n in laws]:
        blk = next(b for b in parsed_file if b[1] == law)
        _, n, params, st = blk
        names = {pname(p) for p in params}

        def qual(s):
            return re.sub(r'(?<![\w.])([A-Za-z_]\w*)(?=[({])', lambda m: f'PRV.{m.group(1)}' if m.group(1) in local and m.group(1) not in names else m.group(1), s)
        ps = ', '.join(qual(p) for p in params)
        args = ', '.join(pname(p) for p in params)
        L.append(f'def {X}__{kind}__{law}({ps}) -> {qual(st)}:')
        L.append(f'  PRV.{law}({args})')
        L.append('')
    return '\n'.join(L) + '\n'


def required_laws():
    """{name: [law names that must prove decode_offsets]} (manual audit round 14, a02/25 and a02/05): every name with a checked decoder has
    the storage law at its own valid size; every list, byte list and progressive list has the empty-input decode law"""
    from codegen.core import fulu_schema_loader as schema
    from codegen.core import generic_form_schemas as generic
    kinds = {n: t.kind for n, t in schema.load(ROOT / 'codegen/fulu.yaml').items() if t is not None}
    kinds.update({n: t.kind for n, t, e in generic.inventory_all() if e is None})
    req = {}
    for f in ('fulu', 'generic'):
        for X in re.findall(r'^def (\w+)_decode_checked\(buf: B\.Buf, \+size: U32\)', RR.mono_text(f), re.M):
            req.setdefault(X, []).append(f'{X}_decode_vchecked_storage_size')
            if kinds.get(X) in ('list', 'bytelist', 'plist'):
                req[X].append(f'{X}_decode_vchecked_empty')
    return req


def outputs():
    fulu, gen, ent, parsed = scan()
    U = set(fulu) | set(gen)
    lack = sorted((X, law) for X, laws in required_laws().items() if X in U for law in laws
                  if law not in {n for _, n in ent.get((X, 'decode_offsets'), [])})
    if lack:
        raise SystemExit(f'api gate: required decode_offsets laws missing ({len(lack)}): {lack[:5]}')
    amap = {}
    missing = []
    for X in fulu + gen:
        row = {}
        for kind in KINDS:
            prv = ent.get((X, kind), [])
            row[kind] = [{'file': f, 'law': n} for f, n in prv]
            if not prv and kind in CORE:
                missing.append((X, kind))
        amap[X] = row
    out = {}
    out[OUT / 'api_map.json'] = json.dumps({'fulu': fulu, 'generic': gen, 'core_laws': CORE, 'laws': KINDS, 'map': amap},
                                           indent=1, sort_keys=False) + '\n'
    lines = ['# GENERATED by object_api_coverage_gate (codegen). Do not edit.',
             '# Every (name, law) of the object API\'s core laws with no proving law in proofs/obj',
             f'# ({len(missing)} of {len(fulu + gen) * len(CORE)}; names: {len(fulu)} Fulu, {len(gen)} generic).',
             '# name law']
    lines += [f'{X} {k}' for X, k in missing]
    out[OUT / 'MISSING.txt'] = '\n'.join(lines) + '\n'
    byfile = {}
    for (X, kind), prv in ent.items():
        for f, n in prv:
            byfile.setdefault(f, {}).setdefault(X, []).append((kind, n))
    for f, xs in sorted(byfile.items()):
        xlaws = [(X, sorted(set(laws), key=lambda kn: (KINDS.index(kn[0]), kn[1]))) for X, laws in sorted(xs.items())]
        out[gate_path(f)] = gate_module(xlaws, f, parsed[f], proof_path(f).read_text())
    return out


def gate_files():
    """every gate module on disk: proofs/gate/g__*.bend and everything under proofs/gate/slop/"""
    if not OUT.exists():
        return []
    return list(OUT.glob('*g_*.bend')) + sorted((OUT / 'slop').rglob('*.bend'))


def main():
    out = outputs()
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in out.items() if not p.exists() or p.read_text() != t]
        mine = gate_files()
        orphans = [str(q.relative_to(ROOT)) for q in mine if q not in out]
        if stale or orphans:
            print('stale api gate: ' + ', '.join((stale + orphans)[:20]) + (' ...' if len(stale + orphans) > 20 else ''))
            sys.exit(1)
        print('api gate is current')
        return
    OUT.mkdir(exist_ok=True)
    for q in gate_files():
        if q not in out:
            q.unlink()
    for p, t in out.items():
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(t)
    print(f'{len(out)} files')


if __name__ == '__main__':
    main()
