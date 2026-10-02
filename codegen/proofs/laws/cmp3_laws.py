#!/usr/bin/env python3
"""Proof laws for three mutation classes the earlier laws left open (auditor round on 9e96b9d5).

    python3 codegen/proofs/laws/cmp3_laws.py [--check]

1. The guard of the fixed-size writers (`P_put(out, pos, o) = P_pwd(U32.is_eq((pos .&. 3), 0), (pos .&. 3), out, pos >> 2, w..)`).
   zpwdcmp_<X>.bend: <X>_cmp_pwd, for every s, out, q and word values w..:
       {T.P_pwd(U32.is_le(s, 0), s, out, q, w..) == T.P_pwd(U32.is_eq(s, 0), s, out, q, w..) : Array<U32>}
   by the lemma `le_eq` of zpwdcmp_lib.bend, `U32.is_le(x, 0) == U32.is_eq(x, 0)` for every symbolic x (U32.cmp is Nat.cmp of the
   values; Nat.cmp(n, 0) is EQ for 0 and GT otherwise): a guard written is_le is the original guard, so those mutants are
   equivalent, and the statement is about P_pwd, so it does not change with the mutation. (is_lt and is_ge are not
   equivalent: is_lt(x, 0) is never true, which sends an aligned position to the unaligned writer P_pwu, whose default
   case is the three-byte shift, and is_ge(x, 0) is always true; the statements about the encoders kill both.)
2. The accumulator of a record's checked writer (`P_pw0(pos, 0, ..)`: its second argument is OR-ed with the flag of the boxed
   child and read only through `is_poisoned` (bit 31) by the serializer, so a start of 1 is invisible to every
   statement about the bytes). zflag_<X>.bend: <X>_cf_flag, the flag `X_putk` reports for the default object of the name
   is 0: {snd(snd(T.X_putk(O.out_at(d), 0, T.X_default()))) == 0}, by computation. A start other than 0 fails it.
3. The arm offsets of a union's reader and validator. zuarm_<X>.bend: <X>_ua_<helper>_<t|f>, for every arm helper
   `X_ok<i>` / `X_rd<i>` (symbolic selector, buffer, offset and length): the arm the flag chooses reads its payload at
   offset + 1 with length - 1 (the selector is one byte), stated against the helper's own body with the schema's constant
   written out, e.g.
       {T.X_rd1(False{}, s, buf, off, len) == T.X_rw0(T.P_read(buf, (off + 1 : U32), (len - 1 : U32))) : ..}
   (the payload of the fall-through arm has no seed: mutation_laws_small.py's witnesses skip it).

Named so that api_gate files them (encode_eval for 1 and 2, ok_eval for 3); the modules are z-prefixed so that they sort
after the name's own proving files.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import writer  # noqa: E402
from codegen.impl import runtime_refs as RR  # noqa: E402
from codegen.core.paths import ROOT  # noqa: E402
from codegen.proofs.collections.laws import qual  # noqa: E402

MAX_DEPTH = 10


def qtype(r):
    return ' & '.join(t.strip() if t.strip().startswith('B.') or t.strip() in ('Bool', 'U32') else qual(t.strip()) for t in r.split(' & '))


def qexpr(e):
    return re.sub(r'(?<![\w.])([A-Za-z_]\w*)(?=\()', r'T.\1', e)


def lib_module():
    L = ['import Base', 'import ../compact/found.bend as F', '', writer.header('cmp3_laws'),
         '# U32.is_le(x, 0) is U32.is_eq(x, 0) for every x (codegen/proofs/laws/cmp3_laws.py).', '',
         'def cl(+n: Nat) -> {Cmp.is_le(Nat.cmp(n, 0n)) == Cmp.is_eq(Nat.cmp(n, 0n)) : Bool}:', '  match n:', '    case 0n: {==}',
         '    case 1n+ +p: {==}', '',
         'def le_eq(+x: U32) -> {U32.is_le(x, 0) == U32.is_eq(x, 0) : Bool}:',
         '  %Equal.sym(Cmp, U32.cmp(x, 0), Nat.cmp(U32.to_nat(x), U32.to_nat(0)), F.u32__u32_cmp(x, 0)) :',
         '    {Cmp.is_le(_) == Cmp.is_eq(_) : Bool}',
         '  cl(U32.to_nat(x))', '']
    return '\n'.join(L)


def name_laws(runtime):
    text = RR.mono_text(runtime)
    pwd, flag, uarm = {}, {}, {}
    # 1: the fixed-size writers' guard
    for m in re.finditer(r'^def (\w+)_encode\((\+?o: [\w.]+)\) -> [^\n:]*: O\.out_done\((\d+), (\w+)_put\(O\.out_at\((\d+)n\), 0, o\)\)$', text, re.M):
        X, P = m.group(1), m.group(4)
        ms = re.search(rf'^def {P}_pwd\(aligned: Bool, \+s: U32, out: Array<U32>, \+q: U32((?:, \+w\d+: U32)+)\) -> Array<U32>:', text, re.M)
        mp = re.search(rf'{P}_pwd\(U32\.is_eq\(\(pos \.&\. 3 : U32\), 0\), \(pos \.&\. 3 : U32\), out, U32\.shrn\(pos, 2n\), ', text)
        if ms and mp:
            ws = re.findall(r'\+w\d+', ms.group(1))
            args = ', '.join(w.lstrip('+') for w in ws)
            sig = ', '.join(f'{w}: U32' for w in ws)
            pwd[X] = (f'def {X}_cmp_pwd(+s: U32, out: Array<U32>, +q: U32, {sig})\n'
                      f'    -> {{T.{P}_pwd(U32.is_le(s, 0), s, out, q, {args}) == T.{P}_pwd(U32.is_eq(s, 0), s, out, q, {args}) : Array<U32>}}:\n'
                      f'  %Equal.sym(Bool, U32.is_le(s, 0), U32.is_eq(s, 0), ZL.le_eq(s)) :\n'
                      f'    {{T.{P}_pwd(_, s, out, q, {args}) == T.{P}_pwd(U32.is_eq(s, 0), s, out, q, {args}) : Array<U32>}}\n'
                      f'  {{==}}')
    # 2: the accumulator of a record's checked writer
    for m in re.finditer(r'^def (\w+)_encode\(o: ([\w.]+)\) -> [^\n:]*: \w+_enc_(?:out|put)\((\w+)_put(?:n)?\(O\.out_at\((\d+)n\), 0, o\)\)$', text, re.M):
        X, d = m.group(1), int(m.group(4))
        R = m.group(2)
        pk = re.search(rf'^def {X}_putk\(out: Array<U32>, \+pos: U32, o: ([\w.]+)\) -> Array<U32> & \(([\w.]+) & U32\):\n  match o:\n    case [^\n]*: \w+_pw0\(pos, 0, ', text, re.M)
        if pk and d <= MAX_DEPTH and re.search(rf'^def {X}_default\(\)', text, re.M):
            Q = qual(R)
            flag[X] = (f'def {X}_cf_flag()\n    -> {{Pair.snd({Q}, U32, Pair.snd(Array<U32>, {Q} & U32, T.{X}_putk(O.out_at({d}n), 0, T.{X}_default()))) == 0 : U32}}:\n  {{==}}')
    # 3: the arm offsets of a union
    for m in re.finditer(r'^def (\w+)_(ok|rd)(\d+)\(c: Bool, \+s: U32, buf: B\.Buf, \+off: U32, \+len: U32\) -> ([^\n:]*):\n  match c:\n    case True\{\}: ([^\n]*)\n    case False\{\}: ([^\n]*)$', text, re.M):
        X, kind, i, ret, te, fe = m.groups()
        for tag, e, cv in (('t', te, 'True{}'), ('f', fe, 'False{}')):
            uarm.setdefault(X, []).append(
                f'def {X}_ua_{kind}{i}_{tag}(+s: U32, buf: B.Buf, +off: U32, +len: U32)\n    -> {{T.{X}_{kind}{i}({cv}, s, buf, off, len) == {qexpr(e)} : {qtype(ret)}}}:\n  {{==}}')
    return pwd, flag, uarm


def module(tmod, X, laws, lib=False, tag='zpwdcmp'):
    L = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O']
    if lib:
        L.append('import ./zpwdcmp_lib.bend as ZL')
    L += [f'import ../../types/{tmod}.bend as T', '', writer.header('cmp3_laws'),
          f'# {X}: mutation classes the earlier laws left open (codegen/proofs/laws/cmp3_laws.py). By computation unless noted.', '']
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def main():
    out, cnt, seen = {}, [0, 0, 0], set()
    out[ROOT / 'proofs/obj/zpwdcmp_lib.bend'] = lib_module()
    for runtime, tmod in (('fulu', 'fulu_obj'), ('generic', 'generic_obj')):
        pwd, flag, uarm = name_laws(runtime)
        for X, law in pwd.items():
            if ('p', X) not in seen:
                seen.add(('p', X))
                out[ROOT / f'proofs/obj/zpwdcmp_{X}.bend'] = module(tmod, X, [law], lib=True)
                cnt[0] += 1
        for X, law in flag.items():
            if ('f', X) not in seen:
                seen.add(('f', X))
                out[ROOT / f'proofs/obj/zflag_{X}.bend'] = module(tmod, X, [law])
                cnt[1] += 1
        for X, laws in uarm.items():
            if ('u', X) not in seen:
                seen.add(('u', X))
                out[ROOT / f'proofs/obj/zuarm_{X}.bend'] = module(tmod, X, laws)
                cnt[2] += len(laws)
    orphans = sorted(str(q.relative_to(ROOT)) for pat in ('zpwdcmp_*.bend', 'zflag_*.bend', 'zuarm_*.bend') for q in (ROOT / 'proofs/obj').glob(pat) if q not in out)
    out = RR.rewire_out(out)
    if '--check' in sys.argv:
        return writer.check(out, 'stale cmp3 laws: ', 'cmp3 laws are current', orphans)
    writer.write(out, orphans)
    print(f'{cnt} laws (pwd names, flag names, union arm laws)')


if __name__ == '__main__':
    main()
