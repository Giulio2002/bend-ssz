"""Small text helpers of the Bend proof builders, each of which several generators used to define for itself.

They build fragments of Bend source: nested Nat sums, boolean conjunctions, Con lists, word patterns. Names are the
ones the generators call them by.
"""


def T_(s: str, mp: dict) -> str:
    """`s` with every key of `mp` replaced by its value, the longest keys first (so a key that prefixes another is safe)"""
    for a in sorted(mp, key=len, reverse=True):
        s = s.replace(a, mp[a])
    return s


def _sz(args, first: str) -> str:
    """the Nat sum `first + args[0] + args[1] ...` as left-nested `Nat.add` calls"""
    s = first
    for a in args:
        s = f'Nat.add({s}, {a})'
    return s


def ceil_log2(x: int) -> int:
    """the smallest k with 2^k >= x (0 for x <= 1)"""
    return max(0, (x - 1).bit_length())


def log2c(n: int) -> int:
    """the smallest k with 2^k >= n (0 for n <= 1; same as ceil_log2 but by counting)"""
    k = 0
    while (1 << k) < n:
        k += 1
    return k


def cons(xs, tail: str) -> str:
    """the Bend list `xs[0] :: xs[1] :: ... :: tail` as nested `Con{x, ...}`"""
    e = tail
    for x in reversed(xs):
        e = f'Con{{{x}, {e}}}'
    return e


def cut(text: str, start: str, end: str) -> str:
    """`text` without the span from the first `start` to the first `end` after it (`end` is kept)"""
    a = text.index(start)
    b = text.index(end, a)
    return text[:a] + text[b:]


def fold_and(cs) -> str:
    """the conjunction of the Bend Bool expressions `cs` as right-nested `Bool.and` (`True{}` for none)"""
    if not cs:
        return 'True{}'
    t = cs[-1]
    for c in reversed(cs[:-1]):
        t = f'Bool.and({c}, {t})'
    return t


def generic(lines):
    """the lines of a Fulu module's import header, pointed at the generic suite's object types and schemas"""
    out = []
    for ln in lines:
        ln = ln.replace('import ../../types/fulu_obj.bend as T', 'import ../../types/generic_obj.bend as T')
        ln = ln.replace('import ../../spec/fulu_schemas.bend as Spec', 'import ./generic_specs.bend as Spec')
        out.append(ln)
    return out


def pos(c: int) -> str:
    """the position expression `x` shifted by the literal c words"""
    return 'x' if c == 0 else f'{c}n+x'


posx = pos


def wl(ws) -> str:
    """a Bend list literal of the word expressions `ws`"""
    return '[' + ', '.join(ws) + ']'


def wp(bits) -> str:
    """the U32 word whose bit list is `bits` (WCon chain, closed with one brace per bit)"""
    return 'U32{' + ''.join(f'WCon{{{x}, ' for x in bits) + 'WNil{}' + '}' * len(bits) + '}'


def wpat(bits, tail: str = 'WNil{}') -> str:
    """the WCon pattern of `bits` ending in `tail`"""
    s_ = tail
    for b in reversed(bits):
        s_ = 'WCon{%s, %s}' % (b, s_)
    return s_


def wsplit(a, b, k):
    """(first width term, next position's literal sum, lemma): VBE.win_split[PRKS] with every literal sum
    written small-first, as Nat.add recurses on its first argument (a large first literal would make the
    conversion to the sum's literal recurse once per unit, near the checker's stack limit)."""
    sw1, sw2 = a > b, k > a
    first = f'Nat.add({b}n, {a}n)' if sw1 else f'Nat.add({a}n, {b}n)'
    third = f'Nat.add({a}n, {k}n)' if sw2 else f'Nat.add({k}n, {a}n)'
    lem = {(False, False): 'P', (True, False): 'R', (False, True): 'K', (True, True): 'S'}[(sw1, sw2)]
    return first, third, f'VBE.win_split{lem}'
