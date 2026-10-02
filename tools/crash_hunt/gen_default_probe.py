#!/usr/bin/env python3
"""Round-2 crash hunt: default-fill probe generator. Writes Bend programs that print, for every named type with a
_serialize, the size / ok flag / word checksum of serialize(default()) and the root of default(). Run on the server.

    python3 tools/crash_hunt/gen_default_probe.py --repo . --out DIR [--groups 6]
Prints DIR/dp<k>.bend. Output line per name:  NAME ok=<0|1> size=<n> cs=<u32> root=<8 words>
"""
import argparse, os, re, sys

def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--repo', default='.'); ap.add_argument('--out', required=True); ap.add_argument('--groups', type=int, default=6)
    a = ap.parse_args()
    T = os.path.join(a.repo, 'types')
    names = sorted(f[:-len('_encode_ssz_generated.bend')] for f in os.listdir(T) if f.endswith('_encode_ssz_generated.bend') and '_serialize(' in open(os.path.join(T, f)).read())
    items = []
    for n in names:
        enc = open(os.path.join(T, n + '_encode_ssz_generated.bend')).read()
        htr = open(os.path.join(T, n + '_hashtreeroot_generated.bend')).read()
        dp = os.path.join(T, n + '_def_generated.bend')
        dfn = open(dp).read() if os.path.exists(dp) else ''
        m = re.search(r'^def (\w+)_serialize\((\+?)o: ([^)]*)\) -> (.*?): ', enc, re.M)
        if not m:
            m = re.search(r'^def (\w+)_serialize\((\+?)o: ([^)]*)\) -> (.*)$', enc, re.M)
        sname = m.group(1); ser_pair = '&' in m.group(4).replace('O.Encoded', '').replace('&', '&') and m.group(4).strip() != 'O.Encoded'
        r = re.search(r'^def (\w+)_hash_tree_root\(h: B.Buf, \+?o: [^)]*\) -> (.*?):\s', htr, re.M)
        root_pair = r.group(2).strip() != 'B.Buf & D.Digest'
        defs = [d for d in re.findall(r'^def (\w+)_default\(\)', dfn, re.M) if not d.endswith('_bx') and not re.search(r'_g\d+$', d)]
        if len(defs) != 1 and dfn:
            print('AMBIG default', n, defs, file=sys.stderr)
        rm = re.search(r'^def (\w+)_hash_tree_root\(h: B.Buf, \+?o: ([^)]*)\)', htr, re.M)
        items.append((n, sname, ser_pair, root_pair, defs[0] if defs else None, m.group(3), rm.group(2)))
    os.makedirs(a.out, exist_ok=True)
    per = (len(items) + a.groups - 1) // a.groups
    for g in range(a.groups):
        part = [i for i in items[g * per:(g + 1) * per] if i[4]]
        L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/digest.bend as D', 'import ../../src/obj.bend as O', 'import ../../benchmarks/compact/objio.bend as IOx']
        for n, s, sp, rp, d, st, rt_ in part:
            L.append('import ../../types/%s_def_generated.bend as %s_d' % (n, n))
            L.append('import ../../types/%s_encode_ssz_generated.bend as %s_e' % (n, n))
            L.append('import ../../types/%s_hashtreeroot_generated.bend as %s_h' % (n, n))
        L.append('''
def cs_go(+k: Nat, +i: U32, +acc: U32, pair: B.Buf & U32) -> B.Buf & U32:
  match k:
    case 0n:
      (b, +w) = pair
      (b, (acc * 31 + w : U32))
    case 1n+q:
      (b, +w) = pair
      cs_go(q, (i + 1 : U32), (acc * 31 + w : U32), B.word(b, (i + 1 : U32)))

def cs_fin(pair: B.Buf & U32) -> U32:
  (b, +x) = pair
  x

def cs_pick(zero: Bool, b: B.Buf, +words: U32) -> B.Buf & U32:
  match zero:
    case True{}: (b, 7)
    case False{}: cs_go(U32.to_nat((words - 1 : U32)), 0, 7, B.word(b, 0))

def csum(b: B.Buf, +words: U32) -> U32: cs_fin(cs_pick(U32.is_eq(words, 0), b, words))

def sum_line(label: String, ok: Bool, pair: B.Buf & U32) -> String:
  (b, +n) = pair
  label ++ " ok=" ++ O.pick_str(ok) ++ " size=" ++ U32.show(n) ++ " cs=" ++ U32.show(csum(b, U32.shrn((n + 3 : U32), 2n)))

def enc_line(label: String, e: O.Encoded) -> String:
  match e:
    case O.Encoded{ok, b}: sum_line(label, ok, B.size(b))

def root_str(d: D.Digest) -> String: IOx.words(d)
''')
        # generic helpers can't be polymorphic in Bend: emit per-name wrappers
        calls = []
        for n, s, sp, rp, d, st, rt_ in part:
            ds = '%s_d.%s_default()' % (n, d)
            if sp:
                ser = 'pair_enc_%s(%s_e.%s_serialize(%s))' % (n, n, s, ds)
                L.append('def pair_enc_%s(pair: %s & O.Encoded) -> String:\n  (o, e) = pair\n  enc_line("%s", e)\n' % (n, st, n))
            else:
                ser = 'enc_line("%s", %s_e.%s_serialize(%s))' % (n, n, s, ds)
            if rp:
                L.append('def root_pair_%s(pair: B.Buf & (%s & D.Digest)) -> String:\n  (h, r) = pair\n  (o, d) = r\n  "%s root=" ++ root_str(d)\n' % (n, rt_, n))
                rt = 'root_pair_%s(%s_h.%s_hash_tree_root(O.hasher(), %s))' % (n, n, s, ds)
            else:
                L.append('def root_one_%s(pair: B.Buf & D.Digest) -> String:\n  (h, d) = pair\n  "%s root=" ++ root_str(d)\n' % (n, n))
                rt = 'root_one_%s(%s_h.%s_hash_tree_root(O.hasher(), %s))' % (n, n, s, ds)
            calls.append((ser, rt))
        L.append('def main() -> IO(Unit):\n  do IO<Unit>:')
        for ser, rt in calls:
            L.append('    IO.print(%s)' % ser)
            L.append('    IO.print(%s)' % rt)
        L.append('    IO.print("DONE")')
        open(os.path.join(a.out, 'dp%d.bend' % g), 'w').write('\n'.join(L) + '\n')
    print(len(items), 'names')

main()
