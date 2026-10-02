"""Text helpers shared by the bridge and composed-theorem generators (codegen/proofs/bridges, codegen/proofs/composed).

Everything here returns Bend source text; nothing reads or writes a file.
"""


def unpack_pairs(src, names, indent, tmp='s', start=1, closed=True):
    """The Bend lines that take a nested pair `src` apart into `names`, one binder per line.

    Each line binds a name and the rest of the pair (`tmp<start>`, `tmp<start + 1>`, ...); with `closed` the last
    line binds the last two names together, so `names` has one entry more than there are lines:

        (+T, s1) = s0
        (+dw, s2) = s1
        (+N, +q) = s2          <-  unpack_pairs("s0", ["T", "dw", "N", "q"], indent)
    """
    out, prev = [], src
    for i in range(len(names) - 2 if closed else len(names)):
        cur = f'{tmp}{start + i}'
        out.append(f'{indent}(+{names[i]}, {cur}) = {prev}')
        prev = cur
    if closed:
        out.append(f'{indent}(+{names[-2]}, +{names[-1]}) = {prev}')
    return '\n'.join(out)
