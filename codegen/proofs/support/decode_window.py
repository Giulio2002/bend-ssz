"""The decode window for the laws that state a result of `X_decode(buf, size)`.

`X_decode(buf, size)` refuses a window that is not inside the buffer (docs/CRASH_HUNT.md CH-06; the lemmas are in
codegen/proofs/laws/decode_window_laws.py). Every decode law of the library was proved on the decoder of a window inside the buffer,
which is `X_decode_in(buf, size)`. `wrap(text)` keeps each such law, with its statement, and moves its proof to a law of the same
name with the suffix `_in` that states the result on `X_decode_in`; the law itself then follows by a lemma of the decoder's
window module:

    {None result}  X_win_none(buf, size, NAME_in(args))                        no premise: a window past the end is refused too
    {Some result}  X_win_some(buf, size, result, hle, NAME_in(args))           hle: U32.is_le(size, bsz(buf)) == True{}

`hle` is `{==}` when the size of the buffer evaluates (a literal size), `DWL.le_refl(size)` when the buffer's size field is the
window itself (a buffer `B.Buf{.., n}` or `BF(t, n)` decoded whole), and otherwise the law takes it as a premise (`hwin`, added to
its parameters: the statement changes by that premise, listed in docs/decode_window_statement_diff.md).
"""
import re

LAW = re.compile(r'^law (\w+):$')
DEF = re.compile(r'^def (\w+)\(')
CALL = re.compile(r'^\{(\w+)\.(\w+)_decode\(')
IMPORT = re.compile(r'^import (\S*?)(?:types|src|proofs|spec)/', re.M)


def balanced(s, i, open_='(', close=')'):
    """index of the bracket matching s[i] == open_"""
    d = 0
    for j in range(i, len(s)):
        if s[j] in '({[':
            d += 1
        elif s[j] in ')}]':
            d -= 1
            if d == 0:
                return j
    raise ValueError(s)


def split_top(s):
    out, d, cur = [], 0, ''
    for ch in s:
        if ch in '({[':
            d += 1
        elif ch in ')}]':
            d -= 1
        if ch == ',' and d == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def parse_statement(stmt):
    """(alias, X, buf, size, rhs, ty) of `{A.X_decode(buf, size) == rhs : ty}`, or None"""
    m = CALL.match(stmt)
    if not m:
        return None
    op = stmt.index('(', m.end() - 1)
    cl = balanced(stmt, op)
    args = split_top(stmt[op + 1:cl])
    if len(args) != 2:
        return None
    rest = stmt[cl + 1:]
    if not rest.startswith(' == '):
        return None
    body = rest[4:]
    end = body.rindex('}')
    inner = body[:end]
    # the last ` : ` at depth 0
    d, cut = 0, None
    for j, ch in enumerate(inner):
        if ch in '({[':
            d += 1
        elif ch in ')}]':
            d -= 1
        elif d == 0 and inner.startswith(' : ', j):
            cut = j
    if cut is None:
        return None
    return m.group(1), m.group(2), args[0], args[1], inner[:cut], inner[cut + 3:]


def hle_for(buf, size):
    """the proof of U32.is_le(size, bsz(buf)) == True{}: ({==}, 'refl') or None when it needs a premise"""
    if re.fullmatch(r'\d+', size):
        return '{==}'
    m = re.match(r'^(B\.Buf\{|[\w.]+\()', buf)
    if m:
        op = len(m.group(1)) - 1
        try:
            cl = balanced(buf, op)
        except ValueError:
            return None
        args = split_top(buf[op + 1:cl])
        if args and args[-1] == size and cl == len(buf) - 1:
            return f'DWL.le_refl({size})'
    return None


def block_spans(lines):
    """(start, stmt_start, def_start, end) of every law block: `law NAME:` form and typed `def NAME(...) -> {stmt}:` form"""
    i, n = 0, len(lines)
    while i < n:
        m = LAW.match(lines[i])
        if m:
            name = m.group(1)
            j = i + 1
            while j < n and not lines[j].startswith(f'def {name}('):
                j += 1
            if j >= n:
                i += 1
                continue
            k = j + 1
            while k < n and lines[k] != '' and not lines[k].startswith(('law ', 'def ', 'type ', '# ')):
                k += 1
            yield ('law', i, j, k, name)
            i = k
            continue
        m = DEF.match(lines[i])
        if m:
            name = m.group(1)
            j = i
            while j < n and not (' -> {' in lines[j] and lines[j].rstrip().endswith(':')) and lines[j] != '':
                j += 1
            if j < n and lines[j] != '':
                k = j + 1
                while k < n and lines[k] != '' and lines[k].startswith('  '):
                    k += 1
                yield ('typed', i, j, k, name)
                i = k
                continue
        i += 1


def wrap(text, names):
    """`text` with its laws of X_decode wrapped. `names`: {X: file name of its decoder} (the runtime index)."""
    if '_decode(' not in text or '# decode window' in text:
        return text
    lines = text.split('\n')
    out, used, last = [], set(), 0
    changed = False
    for kind, i, j, k, name in block_spans(lines):
        if kind == 'law':
            # statement: the first `  {` line after the `for` lines, up to the def
            s0 = next(x for x in range(i + 1, j) if lines[x].startswith('  {'))
            stmt = ' '.join(l.strip() for l in lines[s0:j])
        else:
            hdr = ' '.join(l.strip() for l in lines[i:j + 1])
            if ' -> ' not in hdr:
                continue
            stmt = hdr[hdr.index(' -> ') + 4:]
            stmt = stmt[:-1] if stmt.endswith(':') else stmt
        p = parse_statement(stmt)
        if p is None or p[1] not in names:
            continue
        alias, X, buf, size, rhs, ty = p
        fname = names[X]
        used.add(fname)
        none = 'None{}' in rhs.replace(' ', '') and 'Some{' not in rhs
        hle = None if none else hle_for(buf, size)
        out.extend(lines[last:i])
        last = k
        dw = f'DW_{fname}'
        if kind == 'law':
            names_ = [x.strip() for x in lines[j][lines[j].index('(') + 1:lines[j].rindex(')')].split(',') if x.strip()] if '(' in lines[j] else []
            fors = lines[i + 1:s0]
            body = lines[j + 1:k]
            sl = lines[s0:j]
            sl_in = [l.replace(f'{alias}.{X}_decode(', f'{alias}.{X}_decode_in(', 1) if x == 0 else l for x, l in enumerate(sl)]
            defline = lines[j]
            prem = []
            if not none and hle is None:
                fors = fors + ['  for +hwin: {U32.is_le(' + size + ', DWL.bsz(' + buf + ')) == True{} : Bool}']
                names_ = names_ + ['hwin']
                hle = 'hwin'
            args = ', '.join(names_)
            out.append(f'# decode window: the proof is on the decoder of a window inside the buffer')
            out.append(f'law {name}_in:')
            out.extend(l for l in lines[i + 1:s0])
            out.extend(sl_in)
            out.append(defline.replace(f'def {name}(', f'def {name}_in(', 1))
            out.extend(body)
            out.append('')
            out.append(f'law {name}:')
            out.extend(fors)
            out.extend(sl)
            out.append(f'def {name}({", ".join(names_)}):')
            inner_args = ', '.join(x for x in names_ if x != 'hwin')
            if none:
                out.append(f'  {dw}.{X}_win_none({buf}, {size}, {name}_in({inner_args}))')
            else:
                out.append(f'  {dw}.{X}_win_some({buf}, {size}, {rhs}, {hle}, {name}_in({inner_args}))')
        else:
            header = lines[i:j + 1]
            body = lines[j + 1:k]
            sig = ' '.join(l.strip() for l in lines[i:j + 1])
            op = sig.index('(')
            cl = balanced(sig, op)
            params = split_top(sig[op + 1:cl])
            pnames = [re.match(r'\+?(\w+)', q).group(1) for q in params]
            h2 = [l.replace(f'def {name}(', f'def {name}_in(', 1) if x == 0 else l for x, l in enumerate(header)]
            h2 = [l.replace(f'{alias}.{X}_decode(', f'{alias}.{X}_decode_in(', 1) for l in h2]
            out.append('# decode window: the proof is on the decoder of a window inside the buffer')
            out.extend(h2)
            out.extend(body)
            out.append('')
            hdr_lines = list(header)
            if not none and hle is None:
                # a premise: appended to the parameters of the law itself
                sig_open = hdr_lines[0].index('(')
                prem = f'+hwin: {{U32.is_le({size}, DWL.bsz({buf})) == True{{}} : Bool}}'
                # the closing parenthesis of the parameter list is on the line before ` -> `
                k2 = next(x for x in range(len(hdr_lines)) if ' -> {' in hdr_lines[x] or hdr_lines[x].lstrip().startswith('-> {'))
                line = hdr_lines[k2]
                pos = line.index(')', 0) if ' -> {' not in line and not line.lstrip().startswith('-> {') else line.rindex(')', 0, line.index('-> {'))
                hdr_lines[k2] = line[:pos] + ', ' + prem + line[pos:]
                pnames.append('hwin')
                hle = 'hwin'
            out.extend(hdr_lines)
            inner_args = ', '.join(x for x in pnames if x != 'hwin')
            if none:
                out.append(f'  {dw}.{X}_win_none({buf}, {size}, {name}_in({inner_args}))')
            else:
                out.append(f'  {dw}.{X}_win_some({buf}, {size}, {rhs}, {hle}, {name}_in({inner_args}))')
        changed = True
    if not changed:
        return text
    out.extend(lines[last:])
    new = '\n'.join(out)
    # imports
    m = IMPORT.search(new)
    prefix = m.group(1) if m else '../../'
    imps = [f'import {prefix}proofs/obj/decode_window_library_generated.bend as DWL'] + \
           [f'import {prefix}proofs/obj/decode_window_{f}_generated.bend as DW_{f}' for f in sorted(used)]
    ls = new.split('\n')
    at = max(i for i, l in enumerate(ls) if l.startswith('import ')) + 1
    return '\n'.join(ls[:at] + imps + ls[at:])
