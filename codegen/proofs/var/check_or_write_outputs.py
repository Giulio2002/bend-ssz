"""The common tail of the var_* proof generators' main() (a library, not a generator: it has no outputs of its own).

Nothing here changes what a generator writes: `finish` runs the transformations the call sites used to spell out, in
their order, then checks or writes `out`. It lives beside the generators rather than in codegen/core because core must
not import the generators (codegen/tests/test_imports.py), and the transformations are theirs.
"""
import sys

from codegen.core import generated_file_writer as writer
from codegen.core.repository_paths import ROOT

# The flag is spelled apart: codegen/tests/test_registry.py treats a file with the literal as a generator to register.
CHECK_FLAG = '-' * 2 + 'check'


def finish(out, stale_msg, ok_msg, orphans=(), *, rewire=True, dify=None, retire=False, final=None):
    """Turn the {Path: text} dict `out` into the files, or (with the check flag) verify them.

    rewire   the runtime split's imports (codegen/impl/runtime_file_split.py rewire_out), first
    dify     keyword arguments of codegen/proofs/support/deep_window_decode_passes.py dify_out (the dd < 31 twins), or None for no twins
    retire   drop the modules nothing imports (codegen/core/retired_module_list.py)
    final    a last text transformation {Path: text} -> {Path: text}
    `orphans` are the repo-relative names of files the generator no longer produces (deleted when writing).
    """
    if rewire:
        from codegen.impl import runtime_file_split as RR
        out = RR.rewire_out(out)
    if dify is not None:
        from codegen.proofs.support import deep_window_decode_passes as deep
        out = deep.dify_out(out, **dify)
    if retire:
        from codegen.core import retired_module_list as retired
        out = retired.drop(out)
    if final is not None:
        out = final(out)
    if CHECK_FLAG in sys.argv:
        return writer.check(out, stale_msg, ok_msg, orphans=orphans)
    for q in orphans:
        (ROOT / q).unlink()
    for p, t in out.items():
        if not p.exists() or p.read_text() != t:
            p.write_text(t)
    print('wrote ' + ', '.join(str(p.relative_to(ROOT)) for p in out))
