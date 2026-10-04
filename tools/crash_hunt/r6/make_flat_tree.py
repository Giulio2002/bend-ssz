#!/usr/bin/env python3
"""Crash hunt round 6 (a): turn a SCRATCH copy of the tree's structural dump into the Prysm shim's word-granular flat stream.

The shim (prysm-ffi bendssz/flat-generate.patch) answers a decode with `X_flat(o, [])`: `X_dump` with every leaf as whole 32-bit
words (one list item per word instead of per byte). Its per-type code is the dump's with the O.dump_* primitives renamed to O.flat_*,
so redefining the five O.dump_* primitives with the patch's O.flat_* bodies makes every generated `X_dump` compute `X_flat`, and the
object programs' SSZ_MODE 5 (decode, then dump) the shim's decode + flatten. Every item is masked to its low byte so
that the programs File.write_bytes accepts it (same list, same cells; the values are not compared). Never commit the result.

    python3 tools/crash_hunt/r6/make_flat_tree.py SCRATCH_TREE
"""
import re
import sys

p = sys.argv[1] + '/src/obj.bend'
s = open(p).read()

FLAT = '''
def flat_fw_took(t: +List<U32>, pair: Array<U32> & U32) -> Array<U32> & +List<U32>:
  (ws, +w) = pair
  (ws, (w .&. 255 : U32) <> t)

def flat_fw_step(+i: U32, st: Array<U32> & +List<U32>) -> Array<U32> & +List<U32>:
  (ws, t) = st
  flat_fw_took(t, Array.get(U32, ws, i))

def flat_fw_go(+k: Nat, +j: U32, st: Array<U32> & +List<U32>) -> Array<U32> & +List<U32>:
  match k:
    case 0n: st
    case 1n+q: flat_fw_go(q, (j - 1 : U32), flat_fw_step((j - 1 : U32), st))

def flat_fw_fin(st: Array<U32> & +List<U32>) -> +List<U32>:
  (ws, t) = st
  t

def flat_bytes(ws: Array<U32>, +n: U32, t: +List<U32>) -> +List<U32>:
  flat_fw_fin(flat_fw_go(U32.to_nat(U32.shrn((n + 3 : U32), 2n)), U32.shrn((n + 3 : U32), 2n), (ws, t)))

def dump_le(+x: U32, +k: U32, t: +List<U32>) -> +List<U32>:
  match k:
    case 1: (x .&. 255 : U32) <> t
    case 2: (x .&. 65535 : U32) <> t
    case 3: (x .&. 16777215 : U32) <> t
    case _: (x .&. 255 : U32) <> t

def dump_u64(o: U64, t: +List<U32>) -> +List<U32>:
  match o:
    case U64{+lo, +hi}: (lo .&. 255 : U32) <> ((hi .&. 255 : U32) <> t)

def dump_words(w: Words, t: +List<U32>) -> +List<U32>:
  match w:
    case Words{ws, +n}: flat_bytes(ws, n, t)

def dump_words_n(w: Words, t: +List<U32>) -> +List<U32>:
  match w:
    case Words{ws, +n}: (n .&. 255 : U32) <> flat_bytes(ws, n, t)

def dump_bits_n(b: Bits, t: +List<U32>) -> +List<U32>:
  match b:
    case Bits{ws, +k}: (k .&. 255 : U32) <> flat_bytes(ws, U32.shrn((k + 7 : U32), 3n), t)
'''


def drop_def(src, name):
    """remove `def name(...)` and its indented body"""
    m = re.search(r'^def %s\(.*?(?=^\S)' % re.escape(name), src, flags=re.S | re.M)
    if not m:
        raise SystemExit('no def ' + name)
    return src[:m.start()] + src[m.end():]


for n in ('dump_le', 'dump_u64', 'dump_words', 'dump_words_n', 'dump_bits_n'):
    s = drop_def(s, n)
s = s.rstrip('\n') + '\n' + FLAT
open(p, 'w').write(s)
print('flat primitives installed in', p)
