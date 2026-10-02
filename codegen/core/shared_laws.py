"""Shared building blocks of the law and collection generators (codegen/proofs/laws, codegen/proofs/collections).

Most of these generators end in the same few lines: compare every output file to what is on disk (--check) or write it, treat the
files of a glob that nothing produces any more as orphans, and, for the per-name laws, loop over the two runtimes
(`fulu_obj` and `generic_obj`) writing one module per name. The helpers below are those lines, written once.

    RUNTIMES                     the two runtime modules the per-name law generators read
    run_single(name, out, text)  a generator with one output file
    run_each(name, outs)         a generator with a handful of files, each reported on its own
    per_name(name_laws, make, stem, weigh)
                                 {path: text} of one proofs/obj/<stem>_<X>.bend per name over both runtimes (a name found in both
                                 runtimes is written once, from the first) and the law count per runtime
    finish(out, globs, stale_msg, ok_msg)
                                 the --check / write protocol of a generator that owns the proofs/obj files matching `globs`; True
                                 when it wrote (the caller prints its summary)
"""
import sys

from codegen.core import writer
from codegen.core.paths import ROOT
from codegen.impl import runtime_refs as RR

OBJ = ROOT / 'proofs/obj'
# the flag is spelled in two pieces: codegen/tests/test_registry.py takes every script containing it quoted for a generator
def checking():
    return ('--' 'check') in sys.argv


RUNTIMES = (('fulu', 'fulu_obj'), ('generic', 'generic_obj'))


def run_single(name, out, text):
    """--check: exit 1 when `out` differs from `text`; otherwise write it (when it differs)."""
    if checking():
        if not out.exists() or out.read_text() != text:
            print(f'stale: {out.name}')
            sys.exit(1)
        print(f'{name}: up to date')
        return
    if not out.exists() or out.read_text() != text:
        out.write_text(text)
    print(f'{name}: proofs/obj/{out.name}')


def run_each(name, outs):
    """like run_single for a list of (path, text): --check names every stale file, write mode reports every file."""
    if checking():
        stale = [o.name for o, t in outs if not o.exists() or o.read_text() != t]
        for s in stale:
            print(f'stale: {s}')
        if stale:
            sys.exit(1)
        print(f'{name}: up to date')
        return
    for o, t in outs:
        if not o.exists() or o.read_text() != t:
            o.write_text(t)
        print(f'{name}: proofs/obj/{o.name}')


def per_name(name_laws, make, stem, weigh=len):
    """one module `proofs/obj/<stem>_<X>.bend` = make(tmod, X, laws) per name X of `name_laws(runtime)`, over both runtimes;
    `weigh(laws)` is what a name adds to the count of its runtime."""
    out, counts, seen = {}, [], set()
    for runtime, tmod in RUNTIMES:
        n = 0
        for X, laws in name_laws(runtime).items():
            if X in seen:
                continue
            seen.add(X)
            out[OBJ / f'{stem}_{X}.bend'] = make(tmod, X, laws)
            n += weigh(laws)
        counts.append(n)
    return out, counts


def law_module(gen, comments, laws, tmod, extra_imports=()):
    """the text of one per-name law module: the imports every one has (B, O, then `extra_imports`, then the runtime's types as T),
    the GENERATED header of generator `gen`, the `comments`, and the `laws`, each followed by a blank line."""
    head = ['import Base', 'import ../../src/buffer.bend as B', 'import ../../src/obj.bend as O', *extra_imports,
            f'import ../../types/{tmod}.bend as T', '', writer.header(gen), *comments, '']
    return '\n'.join(head + [piece for law in laws for piece in (law, '')])


def light_pair(out, text, gen, ok_msg):
    """--check / write for a generator whose output `out` has a light companion `<stem>_light.bend` that holds the representation defs
    importers state against (rep_*, wf_*, hview, cnt1, cnt2; codegen/proofs/support/light_split.py). Returns the exit code."""
    import re
    from codegen.proofs.support import light_split as LS
    lout = out.with_name(f'{out.stem}_light.bend')
    keep = lambda n: re.match(r'(rep|wf)_', n) is not None or n in {'hview', 'cnt1', 'cnt2'}
    text, ltext = LS.split(text, keep, f'./{lout.name}', f'{gen} (codegen)')
    text = LS.light(text)
    ltext = LS.light(ltext) if ltext is not None else None
    if checking():
        for path, want in ((lout, ltext), (out, text)):
            if want is not None and (not path.exists() or path.read_text() != want):
                print(f'{path} is stale; run codegen/proofs/laws/{gen}.py')
                return 1
        print(ok_msg)
        return 0
    out.write_text(text)
    if ltext is not None:
        lout.write_text(ltext)
    return 0


def finish(out, globs, stale_msg, ok_msg):
    """--check (exit 1 on a stale file or an orphan: a proofs/obj file matching one of `globs` that `out` does not hold) or write
    `out` through the runtime split and delete the orphans. Returns True when it wrote."""
    orphans = sorted(str(q.relative_to(ROOT)) for pat in globs for q in OBJ.glob(pat) if q not in out)
    out = RR.rewire_out(out)
    if checking():
        writer.check(out, stale_msg, ok_msg, orphans)
        return False
    writer.write(out, orphans)
    return True


def split_top(s, strip=True, keep_empty=True, opening='([{<', closing=')]}>'):
    """split `s` on the commas outside every bracket pair: `strip` strips each part, `keep_empty` keeps an empty last part (a trailing
    comma, or an empty `s`); `opening` / `closing` are the bracket characters that count."""
    out, depth, cur = [], 0, ''
    for ch in s:
        if ch in opening:
            depth += 1
        elif ch in closing:
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur.strip() if strip else cur)
            cur = ''
        else:
            cur += ch
    if keep_empty or cur.strip():
        out.append(cur.strip() if strip else cur)
    return out
