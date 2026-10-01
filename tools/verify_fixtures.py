#!/usr/bin/env python3
"""Check that the committed fixtures are the pinned consensus-spec-tests files, byte for byte.

    python3 tools/verify_fixtures.py                     # the committed files against fixtures.manifest.json
    python3 tools/verify_fixtures.py --tarballs [DIR]    # and the manifest against the pinned release tarballs
    python3 tools/verify_fixtures.py --tarballs DIR --record FILE.json   # and write the result for the check stamp

Two links, each checked by sha256:

  1. fixtures/<path> == fixtures.manifest.json[<path>] for every entry. There must be no file under
     fixtures/tests that is not in the manifest. This runs offline (tools/check_fast.sh runs it).
  2. With --tarballs, the release archives of upstream.lock.json ("vectors": general.tar.gz,
     "mainnet_vectors": mainnet.tar.gz) are fetched into DIR (default build/tarballs, kept as a
     cache) unless already there. Each archive's sha256 must be the lock's. Then:
       - every manifest entry must be a member of its archive with the same sha256;
       - every archive member in the manifest's scope must be in the manifest. The scope is
         tests/general/phase0/ssz_generic/ for general.tar.gz and tests/mainnet/fulu/ssz_static/
         for mainnet.tar.gz, so no official case is left out.

Together these tie every fixture the conformance runs read to the pinned upstream release.
"""
import hashlib
import json
import os
import sys
import tarfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCOPES = {'vectors': 'tests/general/phase0/ssz_generic/', 'mainnet_vectors': 'tests/mainnet/fulu/ssz_static/'}


def sha(b):
    return hashlib.sha256(b).hexdigest()


def sha_file(p):
    h = hashlib.sha256()
    with open(p, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def committed(manifest):
    bad = []
    for path, want in sorted(manifest.items()):
        p = ROOT / 'fixtures' / path
        if not p.is_file():
            bad.append('missing fixtures/' + path)
        elif sha_file(p) != want:
            bad.append('fixtures/%s: sha256 %s, manifest %s' % (path, sha_file(p), want))
    have = {str(p.relative_to(ROOT / 'fixtures')) for p in (ROOT / 'fixtures/tests').rglob('*') if p.is_file()}
    extra = sorted(have - set(manifest))
    if extra:
        bad.append('%d files under fixtures/tests are not in the manifest, e.g. %s' % (len(extra), extra[:3]))
    return bad


def fetch(url, dest):
    if not dest.exists():
        tmp = dest.with_suffix('.part')
        with urllib.request.urlopen(url, timeout=120) as r, open(tmp, 'wb') as f:
            while True:
                b = r.read(1 << 20)
                if not b:
                    break
                f.write(b)
        os.replace(tmp, dest)
    return dest


def members(tar_path, prefix):
    """{path: sha256} of the regular members under prefix (a leading './' dropped)"""
    out = {}
    with tarfile.open(tar_path, 'r:gz') as t:
        for m in t:
            name = m.name[2:] if m.name.startswith('./') else m.name
            if m.isfile() and name.startswith(prefix):
                out[name] = sha(t.extractfile(m).read())
    return out


def tarballs(manifest, d):
    lock = json.loads((ROOT / 'upstream.lock.json').read_text())
    bad = []
    d.mkdir(parents=True, exist_ok=True)
    seen = set()
    for key, prefix in SCOPES.items():
        ent = lock[key]
        tp = fetch(ent['url'], d / ent['url'].rsplit('/', 1)[1])
        got = sha_file(tp)
        if got != ent['sha256']:
            bad.append('%s: sha256 %s, upstream.lock.json %s' % (tp.name, got, ent['sha256']))
            continue
        mem = members(tp, prefix)
        mine = {p: h for p, h in manifest.items() if p.startswith(prefix)}
        seen |= set(mine)
        for p, h in sorted(mine.items()):
            if p not in mem:
                bad.append('%s: not in %s' % (p, tp.name))
            elif mem[p] != h:
                bad.append('%s: manifest %s, %s has %s' % (p, h, tp.name, mem[p]))
        left = sorted(set(mem) - set(mine))
        if left:
            bad.append('%d files of %s under %s are not in the manifest, e.g. %s' % (len(left), tp.name, prefix, left[:3]))
    outside = sorted(set(manifest) - seen)
    if outside:
        bad.append('%d manifest entries are outside both archives\' scopes, e.g. %s' % (len(outside), outside[:3]))
    return bad


def main():
    manifest = json.loads((ROOT / 'fixtures.manifest.json').read_text())
    bad = committed(manifest)
    tb = '--tarballs' in sys.argv
    if tb:
        i = sys.argv.index('--tarballs')
        d = Path(sys.argv[i + 1]) if len(sys.argv) > i + 1 else ROOT / 'build/tarballs'
        bad += tarballs(manifest, d)
    if bad:
        print('verify_fixtures: MISMATCH:\n  ' + '\n  '.join(bad[:40]))
        sys.exit(1)
    if tb and '--record' in sys.argv:
        lock = json.loads((ROOT / 'upstream.lock.json').read_text())
        rec = {'fixtures_tarballs_verified': True,
               'fixtures_tarball_sha256': {lock[k]['url'].rsplit('/', 1)[1]: lock[k]['sha256'] for k in SCOPES},
               'fixtures_manifest_sha256': sha_file(ROOT / 'fixtures.manifest.json'), 'fixtures': len(manifest)}
        Path(sys.argv[sys.argv.index('--record') + 1]).write_text(json.dumps(rec, indent=1) + '\n')
    print('verify_fixtures: %d fixture files match fixtures.manifest.json%s' % (
        len(manifest), '; the manifest matches the pinned general.tar.gz and mainnet.tar.gz, members and scope' if tb else ''))


if __name__ == '__main__':
    main()
