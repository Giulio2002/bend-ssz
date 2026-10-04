#!/usr/bin/env python3
"""The root of a packed byte value does not depend on how it is stored (manual spec-mutation audit, round 3: w02, w03, w04, w05).

    python3 codegen/proofs/slop/tight_storage_root.py [--check]

Public counterexample: `O.Words{ws, 5}` with a two-word `ws` is `X_valid` (a valid byte list needs only ceil(n / 4) words) and its root is
the root of its five bytes, but a root that takes the whole-chunk fast path, or copies the value badly, hashes the clamped zero chunk (or
the junk past the length). The existing symbolic root laws state the roomy case (storage of whole chunks, `cap` in `proofs/obj/words_root.bend`).

For every name X whose runtime has a packed byte list `p` (length unbounded or at most 256 bytes: `O.words_ok(o, lo, hi, big, 1)` without the
boolean check, whose root is `p_root(hl, h, o, seg)` = `O.words_root` / `O.words_root_prog` behind a length mix) proofs/slop/validity/
<runtime>_<X>_vroot_<p>_generated.bend (X the smallest container using p) holds, symbolic in the hash length `hl` (the SHA of a symbolic
`hl` does not evaluate: both sides are the same stuck term exactly when the same chunks are hashed), the digest of

  <X>_vroot_<p>_tight_5       5 bytes in two words (ceil(n / 4) words exactly)         = the same bytes in a whole chunk of words
  <X>_vroot_<p>_tight_junk_5  the same with three junk bytes after the length          = the same (the clean copy)
  <X>_vroot_<p>_roomy_junk_5  a whole chunk holding junk after the length (word 1 and words 2, 7)  = the clean bytes
  <X>_vroot_<p>_slack_junk_5  four words, junk after the length                        = the clean bytes
  <X>_vroot_<p>_short_5       one word for 5 bytes (the storage holds no chunk)        = the same with a zero word (the hashed chunks are the stored ones: none)
  <X>_vroot_<p>_junk_41       41 bytes in 16 words, junk in word 10 (the tail) and 11  = the clean bytes (two chunks, remainder 9)
  <X>_vroot_<p>_junk_73       73 bytes in 32 words, junk in word 18 and 19             = the clean bytes (three chunks, remainder 9)
  <X>_vroot_<p>_past_41 / _past_73   the same with a clean tail word and junk only in a word wholly past the length (word 11 / 19)

(the last two only when the type has room for them). Filed by api_gate under `root` (the `_vroot_` late rule).

Round 8 (a03/01: a tail test that read bytes 2..3 of a 1-byte tail): for every packed list or vector of the junk laws below and every tail
length r = n mod 4 in 1..3 its range allows (the least such n), a valid value whose tail word holds ONE junk byte 0xBE at position b (each b in
r..3), proofs/slop/validity/<runtime>_<X>_vrootj1_<p>_generated.bend:

  <X>_vroot_<p>_j1_n<n>_b<b>              its root is the clean value's (the clean-copy path)
  <X>_serialize_vreject_j1_<p>_n<n>_b<b>  `p_valid` is False
  <X>_serialize_vrefuse_j1_<p>_n<n>_b<b>  X's checked serializer refuses it (X itself, or X_set_<field>(X_default(), value); not for a default above 3000 bytes)
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402

WORDS_OK = re.compile(r'^def (\w+)_valid\(o: O\.Words\) -> O\.Words & Bool: O\.words_ok\(o, (\d+), (\d+), (True|False)\{\}, 1\)$', re.M)
ROOT = re.compile(r'^def (\w+)_root\(\+hl: Nat, h: B\.Buf, o: O\.Words, \+seg: U32\) -> B\.Buf & \(O\.Words & D\.Digest\): .*O\.words_root(_prog)?\(hl, h, o, (?:(\d+), )?seg\)\)?$', re.M)
A, B_, JUNK, FILL = 67305985, 2864434181, 3735928559, 286331153       # 0x04030201, 0xAABBCC05, 0xDEADBEEF, 0x11111111
CLEAN5 = {0: A, 1: 5}


def words(log, n, vals):
    arr = f'Array.new(U32, {log}n, 0)'
    for i, v in sorted(vals.items()):
        arr = f'Array.set(U32, {arr}, {i}, {v})'
    return f'O.Words{{{arr}, {n}}}'


def cases(n_max, depth):
    """[(tag, observed storage, the clean storage it must hash like)]: depth the tree depth of the type (None: progressive)"""
    out = []
    room = words(3, 5, CLEAN5)
    if n_max >= 5:
        out += [('tight_5', words(1, 5, CLEAN5), room),
                ('tight_junk_5', words(1, 5, {0: A, 1: B_}), room),
                ('roomy_junk_5', words(3, 5, {0: A, 1: B_, 2: JUNK, 7: FILL}), room),
                ('slack_junk_5', words(2, 5, {0: A, 1: B_, 2: JUNK, 3: FILL}), room),
                ('short_5', words(0, 5, {0: JUNK}), words(0, 5, {}))]
    pat = {i: A + i for i in range(10)}
    if n_max >= 41 and (depth is None or depth >= 1):
        out += [('junk_41', words(4, 41, {**pat, 10: B_, 11: JUNK}), words(4, 41, {**pat, 10: 5})),
                ('past_41', words(4, 41, {**pat, 10: 5, 11: JUNK}), words(4, 41, {**pat, 10: 5}))]
    pat18 = {i: A + i for i in range(18)}
    if n_max >= 73 and (depth is None or depth >= 2):
        out += [('junk_73', words(5, 73, {**pat18, 18: B_, 19: JUNK}), words(5, 73, {**pat18, 18: 5})),
                ('past_73', words(5, 73, {**pat18, 18: 5, 19: JUNK}), words(5, 73, {**pat18, 18: 5}))]
    return out


def owners_of_root(tx, p):
    """the API names whose own definitions call p_root; the smallest first"""
    pat = re.compile(rf'\b{re.escape(p)}_root\(')
    out = []
    for X in sorted(re.findall(r'^def (\w+)_encode\(', tx.text, re.M)):
        mine = [b for n, b in tx.blk.items() if n.startswith(X + '_')]
        if any(pat.search(b) for b in mine):
            out.append((len(mine), X))
    return [X for _, X in sorted(out)]


def laws_of(X, p, T, n_max, depth):
    obs = f'Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, {T}.{p}_root(hl, B.empty(), w, 0)))'
    out = []
    for tag, got, want in cases(n_max, depth):
        out.append((tag, f'def {X}_vroot_{p}_{tag}(+hl: Nat)\n    -> {{{obs.replace("w,", got + ",")} == {obs.replace("w,", want + ",")} : D.Digest}}:\n  {{==}}'))
    return out


def module(tmod, X, p, text):
    return '\n'.join(['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/digest.bend as D', 'import ../../src/obj.bend as O',
                      f'import ../../types/{tmod}.bend as T', '', writer.header('tight_storage_root'),
                      f'# {X}: the root of the byte list {p} does not depend on its storage (manual spec-mutation audit, round 3; docs/mutation_testing/MUTATION_PROOFS.md).', '', text, ''])


def outputs():
    out = {}
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        valid = {m.group(1): (int(m.group(3)), m.group(4) == 'True') for m in WORDS_OK.finditer(tx.text) if int(m.group(2)) == 0}
        for m in ROOT.finditer(tx.text):
            p = m.group(1)
            if p not in valid or 'bools' in tx.blk.get(f'{p}_valid', ''):
                continue
            hi, big = valid[p]
            owners = owners_of_root(tx, p)
            if not owners:
                continue
            X = owners[0]
            depth = None if m.group(2) else int(m.group(3))
            if depth is not None and depth > 8:       # the tree's width 2^depth is a unary Nat in the checker
                continue
            laws = laws_of(X, p, 'T', 1 << 30 if big else hi, depth)
            if laws:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_vroot_{p}')] = module(tmod, X, p, '\n\n'.join(t for _, t in laws))
    return out


VALID_ANY = re.compile(r'^def (\w+)_valid\(o: O\.Words\) -> O\.Words & Bool: (O\.bools_ok\()?O\.words_ok\(o, (\d+), (\d+), (True|False)\{\}, (\d+)\)\)?$', re.M)


def junk_cases(n, bools):
    """[(tag, observed, clean)] for a valid value of n bytes: junk words past the length, junk in the tail word, the same bytes in tight storage"""
    data = bytes(1 if bools else (i % 250) + 1 for i in range(n))
    w = (n + 3) // 4
    vals = {i: int.from_bytes(data[4 * i:4 * i + 4].ljust(4, b'\0'), 'little') for i in range(w)}
    E = 8 * ((n + 31) // 32)
    log = (E - 1).bit_length()
    clean = words(log, n, vals)
    out = []
    if (1 << log) > w:
        out.append(('j_past', words(log, n, {**vals, w: JUNK, (1 << log) - 1: FILL}), clean))
    if n % 4:
        tail = {**vals, w - 1: vals[w - 1] | (JUNK & ~((1 << (8 * (n % 4))) - 1) & 0xFFFFFFFF)}
        out.append(('j_tail', words(log, n, tail), clean))
    if w & (w - 1) == 0 and w < E:
        tl = (w - 1).bit_length()
        out.append(('j_tight', words(tl, n, vals), clean))
        if n % 4:
            out.append(('j_tight_tail', words(tl, n, {**vals, w - 1: tail[w - 1]}), clean))
    return out


JUNK1 = 0xBE        # one junk byte (round 8: a03/01): a tail test that reads only some of the bytes past the length misses it in the others
SERIALIZE_MAX = 3000


def tails(lo, hi, big, U, n_max=2048):
    """[n]: one valid length per tail length r = n mod 4 in 1..3 (the least one), for a packed collection lo <= n <= hi (no upper bound when big)"""
    out = {}
    for n in range(max(lo, 1), min(n_max, hi if not big else n_max) + 1):
        if n % U == 0 and n % 4 and n % 4 not in out:
            out[n % 4] = n
        if len(out) == 3 or lo == hi:
            break
    return [out[r] for r in sorted(out)]


def junk1_cases(n, bools):
    """[(tag, observed, clean)]: a valid value of n bytes (n mod 4 = r > 0) whose tail word holds ONE junk byte, at each position b in r..3"""
    data = bytes(1 if bools else (i % 250) + 1 for i in range(n))
    w = (n + 3) // 4
    vals = {i: int.from_bytes(data[4 * i:4 * i + 4].ljust(4, b"\0"), "little") for i in range(w)}
    E = 8 * ((n + 31) // 32)
    log = (E - 1).bit_length()
    clean = words(log, n, vals)
    return [(f"n{n}_b{b}", words(log, n, {**vals, w - 1: vals[w - 1] | (JUNK1 << (8 * b))}), clean) for b in range(n % 4, 4)]


def field_of(tx, X, p):
    """(obj, rep): how a Words value w becomes an X to serialize: X itself (its representation is O.Words) or X_set_<field>(X_default(), w) for the
    field whose validity is p_valid; None when neither"""
    sig = tx.blk.get(f"{X}_serialize", "").split("\n", 1)[0]
    if re.match(rf"def {re.escape(X)}_serialize\(o: O\.Words\)", sig):
        return "{w}", "O.Words"
    for n, b in tx.blk.items():
        if re.fullmatch(rf"{re.escape(X)}_(?:g\d+_)?va(?:lid|\d+)", n):     # X_valid, X_va<k> and a group's X_g<k>_valid / _va<k>
            m = re.search(rf"(?<![\w.]){re.escape(p)}_valid\((\w+)\)", b)
            if m:
                st = tx.blk.get(f"{X}_set_{m.group(1)}", "").split("\n", 1)[0]
                if re.search(r", v: O\.Words\) -> \w+:", st):
                    return f"T.{X}_set_{m.group(1)}(T.{X}_default(), {{w}})", re.search(r"-> (\w+):", st).group(1)
    return None


def junk1_outputs(out):
    """(round 8: a03/01, tail_zero tested bytes 2..3 for a tail of 1 byte) every packed list or vector of the j_tail laws, at every tail length its
    range allows, with ONE junk byte past the length in its tail word, at each position: the root is the clean value's (the clean-copy path), the
    collection is not valid, and X's checked serializer refuses it"""
    for runtime, tmod in (("fulu", "fulu_obj"), ("generic", "generic_obj")):
        tx = MC.Text(runtime)
        valid = {m.group(1): (bool(m.group(2)), int(m.group(3)), int(m.group(4)), m.group(5) == "True", int(m.group(6))) for m in VALID_ANY.finditer(tx.text)}
        for m in ROOT.finditer(tx.text):
            p = m.group(1)
            if p not in valid:
                continue
            bools, lo, hi, big, U = valid[p]
            n0 = lo if lo > 0 else U
            if n0 > 2048 or (not big and n0 > hi) or n0 % U:
                continue
            owners = owners_of_root(tx, p)
            if not owners:
                continue
            X = owners[0]
            depth = None if m.group(2) else int(m.group(3))
            if depth is None:
                fn = "O.words_root_prog(hl, B.empty(), w, 0)"
            elif depth <= 8:
                fn = f"T.{p}_root(hl, B.empty(), w, 0)"
            else:
                fn = "O.words_root(hl, B.empty(), w, 8, 0)"
            obs = f"Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, {fn}))"
            ser = field_of(tx, X, p)
            small = MC.default_size(X) is None or MC.default_size(X) <= SERIALIZE_MAX
            laws = []
            for n in tails(lo, hi, big, U):
                for tag, got, want in junk1_cases(n, bools):
                    laws.append(f"def {X}_vroot_{p}_j1_{tag}(+hl: Nat)\n    -> {{{obs.replace('w,', got + ',', 1)} == {obs.replace('w,', want + ',', 1)} : D.Digest}}:\n  {{==}}")
                    laws.append(f"def {X}_serialize_vreject_j1_{p}_{tag}()\n    -> {{Pair.snd(O.Words, Bool, T.{p}_valid({got})) == False{{}} : Bool}}:\n  {{==}}")
                    if ser and small:
                        obj, rep = ser
                        rq = rep if rep == "O.Words" else f"T.{rep}"
                        laws.append(f"def {X}_serialize_vrefuse_j1_{p}_{tag}()\n    -> {{Pair.snd({rq}, O.Encoded, T.{X}_serialize({obj.format(w=got)})) == O.refused() : O.Encoded}}:\n  {{==}}")
            if laws:
                out[LAYOUT.module_path("validity", f"{runtime}_{X}_vrootj1_{p}")] = module(tmod, X, p, "\n\n".join(laws))
    return out


def junk_outputs(out):
    """every packed list or vector whose root is O.words_root (binary) or O.words_root_prog: a valid value with junk in its spare storage hashes like
    the same value in clean storage (round 5: a01/08, the binary twin of the progressive law). A type whose tree is deeper than 2^8 chunks is stated on
    O.words_root at depth 8 (the same code path; its width is a unary Nat in the checker)."""
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = MC.Text(runtime)
        valid = {m.group(1): (bool(m.group(2)), int(m.group(3)), int(m.group(4)), m.group(5) == 'True', int(m.group(6))) for m in VALID_ANY.finditer(tx.text)}
        for m in ROOT.finditer(tx.text):
            p = m.group(1)
            if p not in valid:
                continue
            bools, lo, hi, big, U = valid[p]
            n = lo if lo > 0 else U
            if n > 2048 or (not big and n > hi) or n % U:
                continue
            owners = owners_of_root(tx, p)
            if not owners:
                continue
            X = owners[0]
            prog = bool(m.group(2))
            depth = None if prog else int(m.group(3))
            if prog:
                fn = 'O.words_root_prog(hl, B.empty(), w, 0)'
            elif depth <= 8:
                fn = f'T.{p}_root(hl, B.empty(), w, 0)'
            else:
                fn = 'O.words_root(hl, B.empty(), w, 8, 0)'
            obs = f'Pair.snd(O.Words, D.Digest, Pair.snd(B.Buf, O.Words & D.Digest, {fn}))'
            laws = [f'def {X}_vroot_{p}_{tag}(+hl: Nat)\n    -> {{{obs.replace("w,", got + ",", 1)} == {obs.replace("w,", want + ",", 1)} : D.Digest}}:\n  {{==}}'
                    for tag, got, want in junk_cases(n, bools)]
            if laws:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_vrootj_{p}')] = module(tmod, X, p, '\n\n'.join(laws))
    return out


def main():
    out = junk1_outputs(junk_outputs(outputs()))
    if LAYOUT.finish(RR.rewire_out(out), 'tight_storage_root', ('validity',), 'stale tight storage root laws: ', 'tight storage root laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
