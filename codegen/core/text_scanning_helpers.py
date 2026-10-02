"""Small text helpers shared by the generators outside the bridge partition (witnesses, support, facades, decoded, impl).

Everything here works on strings; nothing reads or writes a file.
"""


def bracket_end(s, k, opens='([{', closes=')]}'):
    """The index of the bracket that closes the one at s[k] (only the given bracket kinds are counted), or None if it is not closed."""
    depth = 0
    for j in range(k, len(s)):
        if s[j] in opens:
            depth += 1
        elif s[j] in closes:
            depth -= 1
            if depth == 0:
                return j
    return None


def close_paren(t, i):
    """The index of the ')' that closes the '(' at t[i]; ValueError if it is not closed."""
    j = bracket_end(t, i, '(', ')')
    if j is None:
        raise ValueError
    return j
