#!/usr/bin/env python3
"""All frozen cases through the GENERATED typed object API, natively.

Every official case (cases.json: 295 ssz_static + 5,145 ssz_generic) is run by
the native C program of the generated object API that holds its type
(benchmarks/objprog/g<k>.bend for the Fulu names, x<k>.bend for the generic
schemas; both are compiled fresh by the pinned Bend (benchmarks/toolchain.json), keyed on the bytes
of their whole import cone, before any case runs). The expected outputs are
never given to the program:

  valid case    the program decodes the official bytes into the typed object
                (mode 0: the generated validator accepts, the reader builds),
                encodes the object into fresh bytes and hashes it; the fresh
                bytes must equal the official bytes and the 32-byte root must
                equal the official root. A second run (mode 5) decodes again
                and writes the object's structural value dump (every leaf from
                its typed field, src/obj.bend `dump_*`); read back here by the
                frozen schema, that value must equal the official value.yaml
                normalized by the frozen tools/test_schemas.py.
  invalid case  the program must refuse the bytes (exit status non-zero with
                DECODED=0 from the generated validator).

A generic schema the generator refuses as not an SSZ type (a zero-length
vector, for instance) has no program; every official case for such a schema
must be an invalid case, which is checked, not assumed.
"""
import argparse
import datetime
import json
import os
import re
import subprocess
import sys
import time
import uuid
from pathlib import Path

import snappy
from ruamel.yaml import YAML

ROOT = Path(__file__).resolve().parents[1]
TOOLCHAIN = json.loads((ROOT / 'benchmarks/toolchain.json').read_text())
FLAGS = ['--threads', '1', '--gpu', 'off']
yaml = YAML(typ='safe')


def build():
    """Compile (or reuse, keyed on the import cone) every program and link
    build/obj-g<k> and build/obj-x<k>; a failed compile removes the link."""
    for flag in ('--build', '--build-generic'):
        r = subprocess.run([sys.executable, 'benchmarks/quick.py', flag, 'all'], cwd=ROOT,
                           capture_output=True, text=True)
        if r.returncode:
            raise SystemExit('native build failed:\n' + r.stdout[-4000:] + r.stderr[-4000:])


# ---- reading the structural value dump back, by the frozen schema ----------

def packed(s):
    """The generator stores a sequence of these elements as packed bytes
    (codegen/impl/typed_object_runtime.py Shape.classify): basic elements and byte vectors of a
    whole number of words."""
    e = s['element']
    return e['kind'] in ('bool', 'uint') or (e['kind'] == 'bytes' and e['length'] % 4 == 0)


def u32(b, i):
    return int.from_bytes(b[i:i + 4], 'little'), i + 4


def bits(raw, n):
    if n % 8 and raw and raw[-1] >> (n % 8):
        raise ValueError('bits past the length are set')
    return [bool(raw[j // 8] & (1 << (j % 8))) for j in range(n)]


def parse(s, b, i):
    k = s['kind']
    if k == 'uint':
        n = s['size']
        return str(int.from_bytes(b[i:i + n], 'little')), i + n
    if k == 'bool':
        if b[i] not in (0, 1):
            raise ValueError('boolean field holds ' + str(b[i]))
        return b[i] == 1, i + 1
    if k == 'bytes':
        n = s['length']
        return list(b[i:i + n]), i + n
    if k == 'bytelist':
        n, i = u32(b, i)
        return list(b[i:i + n]), i + n
    if k == 'bits':
        n = s['length']
        m = (n + 7) // 8
        return bits(b[i:i + m], n), i + m
    if k in ('bitlist', 'progressive_bits'):
        n, i = u32(b, i)
        m = (n + 7) // 8
        return bits(b[i:i + m], n), i + m
    if k == 'vector':
        out = []
        for _ in range(s['length']):
            v, i = parse(s['element'], b, i)
            out.append(v)
        return out, i
    if k in ('list', 'progressive_list'):
        n, i = u32(b, i)
        out = []
        if packed(s):
            end = i + n
            while i < end:
                v, i = parse(s['element'], b, i)
                out.append(v)
            if i != end:
                raise ValueError('packed list length is not a whole number of elements')
        else:
            for _ in range(n):
                v, i = parse(s['element'], b, i)
                out.append(v)
        return out, i
    if k in ('container', 'progressive_container'):
        out = {}
        for name, t in s['fields']:
            out[name], i = parse(t, b, i)
        return out, i
    if k == 'compatible_union':
        sel = b[i]
        v, i = parse(s['options'][s['selectors'].index(sel)], b, i + 1)
        return {'selector': sel, 'value': v}, i
    raise ValueError('no generated form for schema kind ' + k)


def value_of(schema, dump):
    v, i = parse(schema, dump, 0)
    if i != len(dump):
        raise ValueError(f'value dump has {len(dump) - i} unread bytes')
    return v


# ---- running one case ------------------------------------------------------

def run(program, index, mode, data_path, out_path):
    out_path.unlink(missing_ok=True)
    env = {**os.environ, 'BEND_NO_TELEMETRY': '1', 'SSZ_MODE': str(mode), 'SSZ_INDEX': str(index),
           'SSZ_OPS': '1', 'SSZ_INPUT': str(data_path), 'SSZ_OUTPUT': str(out_path)}
    return subprocess.run([str(program)] + FLAGS, env=env, capture_output=True, text=True, timeout=600)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--only', default=None, help='substring filter on case paths (development)')
    args = parser.parse_args()
    sys.path.insert(0, str(ROOT / 'tools'))
    sys.path.insert(0, str(ROOT))
    from test_schemas import for_case, normalize
    from run_evidence import preserve_report, sha256_file
    from codegen.core import generic_form_schemas as GEN
    started = time.monotonic()
    build()
    groups = json.loads((ROOT / 'types/obj_groups.json').read_text())
    gindex = json.loads((ROOT / 'types/generic_obj_index.json').read_text())
    generated, unsupported = gindex['generated'], gindex['unsupported']
    owner = GEN.case_names()
    inventory = json.loads((ROOT / 'cases.json').read_text())
    programs = sorted(ROOT.glob('build/obj-[gx]*'))
    evidence = {
        'backend': 'native C programs of the generated typed object API (benchmarks/objprog/g*.bend, x*.bend '
                   'over types/fulu_obj*.bend and types/generic_obj*.bend) compiled by pinned Bend '
                   + TOOLCHAIN['version'],
        'expected_outputs_sent_to_backend': False,
        'run_id': str(uuid.uuid4()),
        'started_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'workspace': str(ROOT),
        'bend_version': TOOLCHAIN['version'],
        'bend_sha256': sha256_file(TOOLCHAIN['bend']['path']),
        'base_sha256': sha256_file(TOOLCHAIN['base']['path']),
        'inventory_sha256': sha256_file(ROOT / 'cases.json'),
        'programs': {str(p.relative_to(ROOT)): sha256_file(p) for p in programs},
        'source_sha256': {str(p.relative_to(ROOT)): sha256_file(p)
                          for folder, pattern in [('src', '*.bend'), ('types', '*.bend'), ('spec', '*.bend'),
                                                  ('benchmarks/objprog', '*.bend'), ('benchmarks/compact', '*.bend'),
                                                  ('tools', '*.py'), ('codegen', '**/*.py'), ('codegen', '*.yaml')]
                          for p in sorted((ROOT / folder).glob(pattern))},
        'runs': 0,
    }
    tmp = ROOT / 'build/spectests'
    tmp.mkdir(parents=True, exist_ok=True)
    data_path, out_path = tmp / 'case.ssz', tmp / 'case.out'
    rows = []
    for case in inventory:
        row = {'case': case, 'status': 'failed'}
        rows.append(row)
        if args.only and args.only not in case:
            row['error'] = 'not selected'
            continue
        try:
            path = ROOT / 'fixtures' / case
            data = snappy.decompress((path / 'serialized.ssz_snappy').read_bytes())
            valid = '/ssz_static/' in case or case.split('/')[-2] == 'valid'
            if '/ssz_static/' in case:
                name = case.split('/')[4]
                program, index = ROOT / f"build/obj-g{groups[name]['group']}", groups[name]['index']
            else:
                name = owner[case]
                if name in unsupported:
                    # no generated codec: only rejection can be asked of it
                    if valid:
                        raise ValueError('a valid official case for an unsupported schema: ' + unsupported[name])
                    row.update(status='passed', evidence='schema has no SSZ codec (' + unsupported[name]
                               + '); the invalid case is rejected by construction')
                    continue
                program, index = ROOT / f"build/obj-x{generated[name]['group']}", generated[name]['index']
            data_path.write_bytes(data)
            r = run(program, index, 0, data_path, out_path)
            evidence['runs'] += 1
            accepted = r.returncode == 0 and 'DECODED=1' in r.stdout
            if not valid:
                if accepted or 'DECODED=0' not in (r.stdout + r.stderr):
                    raise ValueError('expected the generated validator to reject; exit '
                                     f'{r.returncode}: {(r.stdout + r.stderr)[-300:]}')
                row.update(status='passed', evidence='generated validator rejected the bytes')
                continue
            if not accepted:
                raise ValueError(f'decode refused a valid case; exit {r.returncode}: {(r.stdout + r.stderr)[-300:]}')
            encoded = out_path.read_bytes() if out_path.exists() else None
            if encoded != data:
                raise ValueError('fresh encoding differs from the official bytes')
            m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
            got = b''.join(int(x).to_bytes(4, 'big') for x in m.group(1).split(',')) if m else b''
            root_file = 'roots.yaml' if '/ssz_static/' in case else 'meta.yaml'
            want = bytes.fromhex(yaml.load((path / root_file).read_text())['root'][2:])
            if len(want) != 32 or got != want:
                raise ValueError(f'root mismatch: {got.hex()} != {want.hex()}')
            r = run(program, index, 5, data_path, out_path)
            evidence['runs'] += 1
            if r.returncode or not out_path.exists():
                raise ValueError(f'value dump failed; exit {r.returncode}: {(r.stdout + r.stderr)[-300:]}')
            schema = for_case(case)
            expected = normalize(schema, yaml.load((path / 'value.yaml').read_text()))
            decoded = value_of(schema, out_path.read_bytes())
            if decoded != expected:
                raise ValueError('decoded object value differs from value.yaml')
            row.update(status='passed', evidence='exact official bytes, typed object value and 32-byte root')
        except Exception as exc:
            row['error'] = str(exc)[:2000]
    evidence['complete'] = not args.only
    evidence['finished_utc'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    evidence['seconds'] = round(time.monotonic() - started, 1)
    passed = sum(row['status'] == 'passed' for row in rows)
    report = {'cases': rows, 'evidence': evidence, 'passed': passed, 'failed': len(rows) - passed}
    preserve_report(report, args.report)
    print(f'SSZ: {passed} passed, {len(rows) - passed} failed, {len(rows)} inventoried')
    return 0 if passed == len(inventory) else 1


if __name__ == '__main__':
    sys.exit(main())
