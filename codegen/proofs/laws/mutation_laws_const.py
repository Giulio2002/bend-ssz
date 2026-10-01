#!/usr/bin/env python3
"""Laws that pin constants of the generated encoders the other laws of a name leave to its callers, found by mutation
testing (docs/MUTATION_PROOFS.md, "constant" and "hashtreeroot-constant" survivors).

    python3 codegen/proofs/laws/mutation_laws_const.py [--check]

proofs/obj/mutconst_<X>.bend, one module per name (a facade imports only its own name's laws), holds, for the names
the forms below apply to, laws named <X>_mc_<tag> (api_gate files them in the name's facades by the tag):

  <X>_mc_poison_<P>      the checked writer P_pk marks an invalid value with the runtime's poison marker
      {T.P_pk(out, pos, (o, False{})) == (out, (o, O.poison()))}                  (symbolic)
  <X>_mc_bxpoison_<S>    the boxed checked writer S_bx_putk marks a missing element the same way
      {T.S_bx_putk(out, pos, O.BNone{}) == (out, (O.BNone{}, O.poison()))}        (symbolic)
  <X>_mc_bxcount_<S>     the boxed counting writer S_bx_putn reports 0 bytes for a missing element
      {snd(snd(T.S_bx_putn(out, pos, O.BNone{}))) == 0}                           (symbolic)
  <X>_mc_put             the writer P_put at the unaligned byte positions 1, 2, 3 of a nonzero value equals the
                         runtime's generic writer O.put_words of the value's aligned bytes (a record, Bytes<N> and
                         bitvectors), or of the value itself (a packed collection): the word shifts, the carries and
                         the word indices of the unaligned packing, which the facade statements (all written at
                         position 0) never reach.                                  (by computation)
  <X>_mc_ser             the checked serializer of a witness (a value of the name: its seed, its default, a packed
                         collection / bit list of the least size with nonzero words) is the unchecked encoder's
                         bytes: the encoded length constants of both and the position the serializer writes at.
                                                                                   (by computation)
  <X>_mc_root            the hash_tree_root wrapper of a Merkle-vector or bit-collection name is its root function at
                         the runtime's hasher length (64n) and segment 0 (the digest is independent of both, the
                         returned scratch buffer is not).                           (symbolic)

What is not here, and why (docs/MUTATION_PROOFS.md): a literal argument that the callee never reads cannot be pinned by
any statement (the checker compares by conversion, and the argument disappears): the hasher length and segment of the
leaf wrappers (u8_root ... u256_root and their aliases read neither), the offset of a proglist validator (`P_ok`
ignores it), and the depth of `O.out_at(d)` where 2^d words is merely a larger capacity.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import writer  # noqa: E402
from codegen.core import schema  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402
from codegen.proofs.collections.laws import qual  # noqa: E402
from codegen.proofs.laws import mutation_laws as ML  # noqa: E402
from codegen.core.paths import ROOT  # noqa: E402

SER_MAX = 8192          # bytes: a `_mc_ser` witness is computed through its encoding
PATTERN = (0x9E3779B1, 0x85EBCA6B, 0xC2B2AE35, 0x27D4EB2F)   # nonzero words of a witness


def split_sig(blk):
    """(params [str], ret, body) of one definition block, or None"""
    m = re.match(r'def (\w+)\(', blk)
    if not m:
        return None
    s = blk[m.end() - 1:]
    d, k = 0, None
    for q, c in enumerate(s):
        if c in '([{<':
            d += 1
        elif c in ')]}>':
            d -= 1
            if d == 0 and c == ')':
                k = q
                break
    if k is None:
        return None
    params, rest = s[1:k], s[k + 1:]
    mm = re.match(r'\s*->\s*', rest)
    if not mm:
        return None
    r, d = rest[mm.end():], 0
    for q, c in enumerate(r):
        if c in '([{<':
            d += 1
        elif c in ')]}>':
            d -= 1
        elif c == ':' and d == 0 and (q + 1 == len(r) or r[q + 1] in ' \n'):
            ps, cur, d2 = [], '', 0
            for ch in params:
                if ch in '([{<':
                    d2 += 1
                elif ch in ')]}>':
                    d2 -= 1
                if ch == ',' and d2 == 0:
                    ps.append(cur.strip())
                    cur = ''
                else:
                    cur += ch
            if cur.strip():
                ps.append(cur.strip())
            return ps, r[:q].strip(), r[q + 1:].strip()
    return None


class Text:
    """The definitions of one runtime monolith"""

    def __init__(self, runtime):
        self.text = RR.mono_text(runtime)
        self.blk = {}
        for b in re.split(r'\n(?=def )', self.text):
            m = re.match(r'def (\w+)\(', b)
            if m:
                self.blk[m.group(1)] = b.strip()
        self.sig = {}

    def get(self, name):
        if name not in self.blk:
            return None
        if name not in self.sig:
            self.sig[name] = split_sig(self.blk[name])
        return self.sig[name]


def min_size(t):
    """the encoded size of the least value of the schema type t (lists empty): what its default encodes to"""
    if t.fixed():
        return t.fixed_size()
    if t.kind in ('container', 'pcontainer'):
        return sum(c.fixed_size() if c.fixed() else 4 + min_size(c) for _, c in t.fields)
    if t.kind in ('bitlist', 'pbits'):
        return 1
    return 0


SCHEMA = None


def default_size(X):
    """the encoded size of X's default object (None when X is not a Fulu schema name)"""
    global SCHEMA
    if SCHEMA is None:
        SCHEMA = dict(schema.load(ROOT / 'codegen/fulu.yaml'))
    t = SCHEMA.get(X)
    return None if t is None else min_size(t)


_SEEDS = {}


def seeds_of(tx):
    """{type: the name of its seed function}"""
    if id(tx) not in _SEEDS:
        d = {}
        for nm in tx.blk:
            if nm.endswith('_seed'):
                sg = tx.get(nm)
                if sg and len(sg[0]) == 1:
                    d.setdefault(sg[1], nm)
        _SEEDS[id(tx)] = d
    return _SEEDS[id(tx)]


def pname(p):
    return p.split(':')[0].strip().lstrip('+-@').strip()


def ptype(p):
    return p.split(':', 1)[1].strip()


def words(vals, nbytes):
    """the words of a witness of `nbytes` bytes: PATTERN cycled, all nonzero"""
    return [PATTERN[i % len(PATTERN)] for i in range((nbytes + 3) // 4)]


def depth_for_words(nw):
    k = 0
    while (1 << k) < nw:
        k += 1
    return k


def words_witness(n, nonzero_all=True, bools=False):
    """an O.Words of `n` bytes: zeros with nonzero words written at the start (and the end)"""
    ws = [(PATTERN[i % 4] & 0x01000101) if bools else PATTERN[i % 4] for i in range((n + 3) // 4)]
    if n % 4:
        ws[-1] &= (1 << (8 * (n % 4))) - 1      # no bytes past the end
    idx = sorted({0, len(ws) - 1}) if not nonzero_all else list(range(len(ws)))
    e = f'O.words_new({n})'
    for j in idx:
        e = f'O.words_setw({e}, {j}, {ws[j]})'
    return e


def build_name_laws(tx, X, idx, files, syms):
    """[(tag, law text)] for the name X of runtime `tx`"""
    laws = []
    enc = tx.get(f'{X}_encode')
    if enc is None:
        return laws
    eparams, eret, ebody = enc
    R = ptype(eparams[0])
    fidx = syms.get(f'{X}_encode')
    here = lambda sym: syms.get(sym) == fidx   # noqa: E731  the symbol lives in this name's encode file
    # ---- poison markers ---------------------------------------------------------------------
    for nm in sorted(tx.blk):
        if not here(nm):
            continue
        b = tx.blk[nm]
        m = re.fullmatch(r'(\w+)_pk', nm)
        if m and re.search(r'case False\{\}: \(out, \(o, 2147483648\)\)$', b):
            sg = tx.get(nm)
            A = ptype(sg[0][2]).rsplit(' & ', 1)[0]
            QA = qual(A)
            laws.append((f'poison_{m.group(1)}',
                         f'def {X}_mc_poison_{m.group(1)}(out: Array<U32>, pos: U32, o: {QA})\n'
                         f'    -> {{T.{nm}(out, pos, (o, False{{}})) == (out, (o, O.poison())) : Array<U32> & ({QA} & U32)}}:\n  {{==}}'))
        m = re.fullmatch(r'(\w+)_bx_putk', nm)
        if m and re.search(r'case O\.BNone\{\}: \(out, \(O\.BNone\{\}, 2147483648\)\)$', b):
            sg = tx.get(nm)
            Bx = ptype(sg[0][2])         # O.Boxed<A>
            A = Bx[len('O.Boxed<'):-1]
            QB = 'O.Boxed<' + qual(A) + '>'
            laws.append((f'bxpoison_{m.group(1)}',
                         f'def {X}_mc_bxpoison_{m.group(1)}(out: Array<U32>, pos: U32)\n'
                         f'    -> {{T.{nm}(out, pos, O.BNone{{}}) == (out, (O.BNone{{}}, O.poison())) : Array<U32> & ({QB} & U32)}}:\n  {{==}}'))
        m = re.fullmatch(r'(\w+)_bx_putn', nm)
        if m and re.search(r'case O\.BNone\{\}: \(out, \([\w.()]+, 0\)\)$', b):
            sg = tx.get(nm)
            Bx = ptype(sg[0][2])
            A = Bx[len('O.Boxed<'):-1]
            QB = 'O.Boxed<' + qual(A) + '>'
            laws.append((f'bxcount_{m.group(1)}',
                         f'def {X}_mc_bxcount_{m.group(1)}(out: Array<U32>, pos: U32)\n'
                         f'    -> {{Pair.snd({QB}, U32, Pair.snd(Array<U32>, ({QB} & U32), T.{nm}(out, pos, O.BNone{{}}))) == 0 : U32}}:\n  {{==}}'))
    # ---- unaligned writes ---------------------------------------------------------------------
    mr = re.search(r'\b(\w+)_put\(O\.out_at\((\d+)n\), 0, o\)', ebody)
    if mr:
        P, K = mr.group(1), int(mr.group(2))
        pb = tx.blk.get(f'{P}_put', '')
        nb = re.search(r'O\.out_done\((\d+), ', ebody)
        dflt = tx.get(f'{P}_default')
        if nb and dflt and f'{P}_pw' in pb and R == dflt[1]:
            N = int(nb.group(1))
            cnt = len(re.findall(r'\d+', tx.blk[f'{P}_default'].split(':', 1)[1].split('{', 1)[1]))
            vals = [PATTERN[i % 4] for i in range(cnt)]
            w = f'T.{R}{{{", ".join(map(str, vals))}}}'
            k = depth_for_words(((3 + N + 3) >> 2) + 2)
            Z = f'O.out_at({k}n)'
            E = f'T.{P}_put(O.out_at({K}n), 0, {w})'
            ref = lambda p: f'Pair.fst(Array<U32>, O.Words, O.put_words({Z}, {p}, O.Words{{{E}, {N}}}))'   # noqa: E731
            laws.append(('put',
                         f'def {X}_mc_put()\n    -> {{(T.{P}_put({Z}, 0, {w}), (T.{P}_put({Z}, 1, {w}), (T.{P}_put({Z}, 2, {w}), T.{P}_put({Z}, 3, {w})))) == '
                         f'({ref(0)}, ({ref(1)}, ({ref(2)}, {ref(3)}))) : Array<U32> & (Array<U32> & (Array<U32> & Array<U32>))}}:\n  {{==}}'))
    mw2 = re.search(r'\b(\w+)_enc_out\((\w+)_put\(O\.out_at\((\d+)n\), 0, o\)\)', ebody)
    if mw2 and R == 'O.Words':
        P = mw2.group(2)
        pb = tx.blk.get(f'{P}_put', '')
        eo = tx.blk.get(f'{X}_enc_out', '')
        nb = re.search(r'O\.out_done\((\d+), out\)', eo)
        if nb and f'{P}_pw' in pb:
            N = int(nb.group(1))
            w = words_witness(N)
            k = depth_for_words(((3 + N + 3) >> 2) + 2)
            Z = f'O.out_at({k}n)'
            one = f'Array<U32> & O.Words'
            laws.append(('put',
                         f'def {X}_mc_put()\n    -> {{(T.{P}_put({Z}, 0, {w}), (T.{P}_put({Z}, 1, {w}), (T.{P}_put({Z}, 2, {w}), T.{P}_put({Z}, 3, {w})))) == '
                         f'(O.put_words({Z}, 0, {w}), (O.put_words({Z}, 1, {w}), (O.put_words({Z}, 2, {w}), O.put_words({Z}, 3, {w})))) : ({one}) & (({one}) & (({one}) & ({one})))}}:\n  {{==}}'))
    # ---- the serializer against the encoder ---------------------------------------------------
    ser = tx.get(f'{X}_serialize')
    if ser and eret.endswith(' & B.Buf') and ser[1].endswith(' & O.Encoded'):
        w = None
        sb = '\n'.join(tx.blk.get(f'{X}_{s}', '') for s in ('serialize', 'senc_go', 'senc_sized', 'senc_out', 'senc_put'))
        mp = re.search(r'\b(\w+)_putk\(', sb)
        valid = tx.blk.get(f'{mp.group(1)}_valid', '') if mp else ''
        if R == 'O.Words' and mp:
            mv = re.search(r'O\.words_ok\(o, (\d+), (\d+), (True|False)\{\}, (\d+)\)', valid)
            if mv and ML.valid_bytes(tx.text, mp.group(1)) is None:
                lo, hi, big, unit = int(mv.group(1)), int(mv.group(2)), mv.group(3) == 'True', int(mv.group(4))
                n = lo if (lo == hi and not big) else unit * 2
                if 0 < n <= SER_MAX:
                    w = words_witness(n, bools='bools_ok' in valid)
        elif R == 'O.Bits' and mp:
            mv = re.search(r'O\.bits_ok\(o, (\d+), (True|False)\{\}\)', valid)
            if mv:
                lim, big = int(mv.group(1)), mv.group(2) == 'True'
                k = 21 if big or lim > 21 else lim
                if k >= 1:
                    pat = PATTERN[0] & ((1 << k) - 1)
                    w = f'O.bits_setw(O.bits_zeros({k}), 0, {pat})'
        elif not R.startswith('O.'):
            sd = f'{X}_seed'
            if tx.get(sd) and tx.get(sd)[1] == R and (default_size(X) or 0) <= SER_MAX:
                w = f'T.{sd}(2271560481)'
            elif tx.get(f'{X}_default') and tx.get(f'{X}_default')[1] == R and (default_size(X) or 0) <= SER_MAX:
                w = f'T.{X}_default()'
                # a default is all zeros when nothing is variable: set one field that has a seed
                for nm in sorted(tx.blk):
                    ms = re.fullmatch(rf'{re.escape(X)}_set_\w+', nm)
                    sg = tx.get(nm) if ms else None
                    if sg and len(sg[0]) == 2 and sg[1] == R and ptype(sg[0][0]) == R and ptype(sg[0][1]) in seeds_of(tx):
                        w = f'T.{nm}({w}, T.{seeds_of(tx)[ptype(sg[0][1])]}(2271560481))'
                        break
        if w:
            QR = qual(R)
            enc_ = f'T.{X}_encode({w})'
            laws.append(('ser',
                         f'def {X}_mc_ser()\n    -> {{T.{X}_serialize({w}) == (Pair.fst({QR}, B.Buf, {enc_}), O.encoded(Pair.snd({QR}, B.Buf, {enc_}))) : {QR} & O.Encoded}}:\n  {{==}}'))
    # ---- the root wrapper -----------------------------------------------------------------------
    rw = tx.get(f'{X}_hash_tree_root')
    if rw:
        m = re.fullmatch(r'(\w+)\(64n, h, o, 0\)', rw[2])
        if m:
            callee = tx.blk.get(m.group(1), '')
            cs = tx.get(m.group(1))
            if cs and re.fullmatch(r'O\.(words|bits)_root\(hl, h, o, \w+, seg\)', cs[2]):
                ps = ', '.join(f'{pname(p)}: {ptype(p)}' for p in rw[0])
                ret = rw[1]
                laws.append(('root',
                             f'def {X}_mc_root({ps})\n    -> {{T.{X}_hash_tree_root(h, o) == T.{m.group(1)}(64n, h, o, 0) : {ret}}}:\n  {{==}}'))
    return laws


def module(tmod, laws_by_name):
    out = {}
    for X, laws in laws_by_name.items():
        L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', 'import ../../src/digest.bend as D',
             f'import ../../types/{tmod}.bend as T', '', writer.header('mutation_laws_const'),
             f'# {X}: constants of the generated encoder / serializer / root wrapper the other laws leave to callers',
             '# (mutation testing; docs/MUTATION_PROOFS.md, section 5). Each law is symbolic or by computation.', '']
        for tag, text in laws:
            L.append(text)
            L.append('')
        out[ROOT / f'proofs/obj/mutconst_{X}.bend'] = '\n'.join(L)
    return out


def outputs():
    files, syms, monos = RR.index()
    out, seen = {}, set()
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        tx = Text(runtime)
        names = sorted(set(re.findall(r'^def (\w+)_encode\(', tx.text, re.M)) - seen)
        by = {}
        for X in names:
            laws = build_name_laws(tx, X, None, files, syms)
            if laws:
                by[X] = laws
        seen |= set(names)
        out.update(module(tmod, by))
    return out


def main():
    out = outputs()
    orphans = sorted(str(q.relative_to(ROOT)) for q in (ROOT / 'proofs/obj').glob('mutconst_*.bend') if q not in out)
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale mutation const laws: ', 'mutation const laws are current', orphans)
    writer.write(out, orphans)
    print(f'{len(out)} modules, {sum(t.count(chr(10) + "def ") for t in out.values())} laws')


if __name__ == '__main__':
    main()
