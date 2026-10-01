"""Symbolic evaluation of U32 bit operations as the stock Bend kernel reduces them
(Bool.and / Bool.or reduce only on a constructor first argument), and the per-bit
lemmas that simplify what stays stuck. Used by codegen/proofs/laws/sub_laws.py to prove facts
about words built with masks and shifts, bit by bit (each bit lemma splits at most
two variables: no case split over byte values)."""
import itertools
import re

T, F = 'True{}', 'False{}'


def band(x, y):
    if x == T:
        return y
    if x == F:
        return F
    return f'Bool.and({x}, {y})'


def bor(x, y):
    if x == T:
        return T
    if x == F:
        return y
    return f'Bool.or({x}, {y})'


def const(c):
    return [T if (c >> i) & 1 else F for i in range(32)]


def and_(X, Y):
    return [band(x, y) for x, y in zip(X, Y)]


def or_(X, Y):
    return [bor(x, y) for x, y in zip(X, Y)]


def shln(X, k):
    return [F] * k + X[:32 - k]


def shrn(X, k):
    return X[k:] + [F] * k


def word(name):
    return [f'{name}{i}' for i in range(32)]


VAR = re.compile(r'(?<![.\w])([a-z]\w*)')


def evaluate(expr, env):
    """The value of a bit expression under env (var -> bool)."""
    e = expr.replace('True{}', 'True').replace('False{}', 'False')
    e = e.replace('Bool.and', '_and').replace('Bool.or', '_or')
    return eval(e, {'_and': lambda a, b: a and b, '_or': lambda a, b: a or b, 'True': True, 'False': False}, env)


def simplify(expr):
    """(simplified, vars): the constant or single variable the bit equals."""
    vs = sorted(set(VAR.findall(expr)))
    if not vs:
        return expr, vs
    table = {}
    for vals in itertools.product([False, True], repeat=len(vs)):
        table[vals] = evaluate(expr, dict(zip(vs, vals)))
    outs = set(table.values())
    if outs == {False}:
        return F, vs
    if outs == {True}:
        return T, vs
    for i, v in enumerate(vs):
        if all(table[vals] == vals[i] for vals in table):
            return v, vs
    raise ValueError('bit is not a variable or a constant: ' + expr)


class Lemmas:
    """Per-bit lemmas, shared by shape."""
    def __init__(self, prefix):
        self.prefix = prefix
        self.defs = {}
        self.lines = []

    def bit(self, expr):
        """(simplified, proof term) of {expr == simplified : Bool}."""
        s, vs = simplify(expr)
        if s == expr:
            return s, '{==}'
        # the shape: rename the variables to v0, v1, ...
        ren = {v: f'v{i}' for i, v in enumerate(vs)}
        shape = VAR.sub(lambda m: ren[m.group(1)], expr)
        ss = VAR.sub(lambda m: ren[m.group(1)], s) if s in ren else s
        key = (shape, ss)
        if key not in self.defs:
            name = f'{self.prefix}{len(self.defs)}'
            self.defs[key] = name
            k = len(vs)
            L = self.lines
            L.append(f'def {name}({", ".join(f"+v{i}: Bool" for i in range(k))}) -> {{{shape} == {ss} : Bool}}:')
            L.append(f'  match {" ".join(f"v{i}" for i in range(k))}:')
            for vals in itertools.product([T, F], repeat=k):
                L.append(f'    case {" ".join(vals)}: {{==}}')
            L.append('')
        return s, f'{self.defs[key]}({", ".join(vs)})'

    def word_eq(self, X, BT='BT'):
        """(Y, proof) with proof : {U32{X} == U32{Y}}."""
        ys, ps = zip(*[self.bit(x) for x in X])
        if all(p == '{==}' for p in ps):
            return list(ys), None
        return list(ys), f'{BT}.word32_eq({", ".join(X)}, {", ".join(ys)}, {", ".join(ps)})'

