"""Where the slop modules live, and the --check / write protocol of the generators that write them.

The laws that exist because mutation testing found a gap in what the statements pin are generated into
proofs/slop/<group>/<name>_generated.bend, one group directory per kind of gap:

    validity     the validity checks of the encoders, the poison flag of the word writers, the refusal of the length check
    size         the reported size of a boxed object and the bound of a byte vector; the write start and the length constants
    capacity     the capacity of the checked serializer's output buffer, concrete and symbolic
    alignment    the choice between the aligned and the general word writer, the guards of the fixed-size writers
    offsets      the offsets the decoders read at and the word positions the writers and readers use
    constants    the constants of the generated encoders and root wrappers
    spec         the constants of the frozen specification that no other law reaches
    crash        the fixes of the crash hunt (docs/CRASH_HUNT.md): refusals and the default's size, by computation

Several generators may write into one group directory: an orphan is a file of the directory whose header names the generator
that is checking (core/generated_file_writer.py `owner`), so one generator never deletes another's file.

A generator writes the text of a module as if it lived in proofs/obj (`import ../../src/obj.bend`, `import ./arr_copy.bend`);
`rebase` moves the imports to the module's real place, one directory deeper. A `./` import of a file the generator writes
into the same directory stays `./`.
"""
import re
from pathlib import Path

from codegen.core import generated_file_writer as writer
from codegen.core.repository_paths import ROOT

PROOFS = ROOT / 'proofs'
SLOP = PROOFS / 'slop'
SUFFIX = '_generated.bend'
GROUPS = ('validity', 'size', 'capacity', 'alignment', 'offsets', 'constants', 'spec', 'crash')

_IMPORT = re.compile(r'^import (\S+)(.*)$', re.M)


def module_path(group: str, name: str) -> Path:
    """proofs/slop/<group>/<name>_generated.bend (every generated file carries `_generated` in its name)"""
    assert group in GROUPS, group
    return SLOP / group / f'{name}{SUFFIX}'


def stem_of(path) -> str:
    """the name of a slop module without the `_generated.bend` suffix (the name its generator gave it)"""
    n = Path(path).name
    return n[:-len(SUFFIX)] if n.endswith(SUFFIX) else Path(n).stem


def rebase(path: Path, text: str, local: set) -> str:
    """`text` (written for proofs/obj) as the module at `path` (proofs/slop/<group>/): `../x` gains one `../`; `./x` names
    a sibling in proofs/obj (`../../obj/x`) unless x is in `local`, the names of the files written beside it."""
    def fix(m):
        target, rest = m.group(1), m.group(2)
        if target.startswith('../'):
            target = '../' + target
        elif target.startswith('./') and target[2:] not in local:
            if target[2:-len('.bend')] + SUFFIX in local:      # a library the generators write beside it (named without the suffix in the text)
                target = './' + target[2:-len('.bend')] + SUFFIX
            else:
                target = '../../obj/' + target[2:]
        return f'import {target}{rest}'
    return _IMPORT.sub(fix, text)


def placed(out: dict) -> dict:
    """`out` ({path: text}) with the imports of every module under proofs/slop rebased."""
    local = {}
    for p in out:
        local.setdefault(p.parent, set()).add(p.name)
    return {p: (rebase(p, t, local[p.parent]) if SLOP in p.parents else t) for p, t in out.items()}


def orphans_of(out: dict, generator: str, groups) -> list:
    """repo-relative names of the files in `groups` whose header names `generator` and that `out` no longer holds."""
    found = []
    for g in groups:
        for q in sorted((SLOP / g).glob('*.bend')):
            if q not in out and writer.owner(q.read_text()) == generator:
                found.append(writer.rel(q))
    return found


def finish(out: dict, generator: str, groups, stale_msg: str, ok_msg: str, check: bool) -> bool:
    """--check (exit 1 on a stale file or an orphan) or write `out` and delete the orphans; True when it wrote."""
    out = placed(out)
    orphans = orphans_of(out, generator, groups)
    if check:
        writer.check(out, stale_msg, ok_msg, orphans)
        return False
    for p in out:
        p.parent.mkdir(parents=True, exist_ok=True)
    writer.write(out, orphans)
    return True


def check_or_write(out: dict, stale_msg: str, ok_msg: str, check: bool) -> None:
    """The protocol of a generator with a fixed set of files (no orphan scan)."""
    out = placed(out)
    if check:
        return writer.check(out, stale_msg, ok_msg)
    for p in out:
        p.parent.mkdir(parents=True, exist_ok=True)
    writer.write(out)
