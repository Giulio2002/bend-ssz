"""Closed bounds of the DataColumnSidecar encoder sizes, on U32 words (no unary Nat of millions): used by codegen/proofs/var/data_column_sidecar_encoder_laws.py."""
import re
from codegen.core.template_loader_positional import Templates  # noqa: E402
TPL = Templates('data_column_sidecar_size_bounds', globals())

X0, X1, QXV = 512 * 4096, 12 * 4096, 89 + 512 * 4096 + 2 * 12 * 4096
TRUE = 'True{} : Bool'


def tn(v):
    return f'U32.to_nat({v})'


def quadw(v):
    return f'U32.add(U32.add({v}, {v}), U32.add({v}, {v}))'


def pw_chain(name, fn, top):
    """{fn(topn) == U32.to_nat(2^top)} by steps pw_s(k, k1, ek, w, e, hc) (k1 = 1n+k stays a literal)."""
    L = [TPL.render('pw_chain', fn=fn, name=name)]
    # one lemma per step (a nested proof term would be re-checked inline); step k's word is the literal 2^k,
    # so the next step compares U32.add(2^k, 2^k) with 2^(k+1) argument-wise, on words
    L.append(f'def {name}0() -> {{{fn}(0n) == U32.to_nat(1) : Nat}}: {{==}}\n')
    for k in range(top):
        w = 1 << k
        L.append(f'def {name}{k + 1}() -> {{{fn}({k + 1}n) == U32.to_nat({2 * w}) : Nat}}:\n'
                 f'  Equal.trans(Nat, {fn}({k + 1}n), U32.to_nat(U32.add({w}, {w})), U32.to_nat({2 * w}), {name}_s({k}n, {k + 1}n, {{==}}, {w}, {name}{k}(), {{==}}),\n'
                 f'    Equal.cong(U32, Nat, z => U32.to_nat(z), U32.add({w}, {w}), {2 * w}, {{==}}))\n')
    return '\n'.join(L)


def text():
    q = quadw(QXV)
    return TPL.render('text', q=q)


def fill(txt):
    '''The encoder text with the closed quantities as words: MX0/MX1/QX are U32.to_nat of literals.'''
    txt = txt.replace('@U32BOUNDS', text())
    for a, b in [('MX0', tn(X0)), ('MX1', tn(X1)), ('QX', tn(QXV))]:
        txt = re.sub(r'(?<![\w.])' + a + r'\(\)', b, txt)
    return txt
