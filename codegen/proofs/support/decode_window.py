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
    """split on the commas outside every bracket pair (round, curly, square, and the angle brackets of a type application)"""
    out, d, cur, ang = [], 0, '', 0
    for x, ch in enumerate(s):
        if ch in '({[':
            d += 1
        elif ch in ')}]':
            d -= 1
        elif ch == '<' and x > 0 and (s[x - 1].isalnum() or s[x - 1] in '._'):
            ang += 1
        elif ch == '>' and ang > 0 and s[x - 1] != '-':
            ang -= 1
        if ch == ',' and d == 0 and ang == 0:
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


def statement_of(lines, kind, i, j):
    if kind == 'law':
        s0 = next((x for x in range(i + 1, j) if lines[x].startswith('  {')), None)
        return None if s0 is None else ' '.join(l.strip() for l in lines[s0:j])
    hdr = ' '.join(l.strip() for l in lines[i:j + 1])
    if ' -> ' not in hdr:
        return None
    stmt = hdr[hdr.index(' -> ') + 4:]
    return stmt[:-1] if stmt.endswith(':') else stmt


def mentions_any(vars_, texts):
    return any(mentions(v, texts) for v in vars_)


def mentions(var, texts):
    return any(re.search(rf'(?<![\w.]){re.escape(var)}(?![\w])', t) for t in texts)


def classify(lines, spans, names):
    """{name: record} of the laws that state a result of X_decode over a symbolic window: the buffer's size field is the window
    (`X_decode(BF(t, n), n)`), or a free buffer is refused (`X_decode(buf, m) == (buf, None{})`)"""
    recs = {}
    for kind, i, j, k, name in spans:
        stmt = statement_of(lines, kind, i, j)
        p = parse_statement(stmt) if stmt else None
        if p is None or p[1] not in names:
            continue
        alias, X, buf, size, rhs, ty = p
        if re.fullmatch(r'\d+', size):
            continue          # a literal window: the guard evaluates
        body_ = [l for l in lines[j + 1:k] if l.strip()]
        if len(body_) == 1 and 'PRV.' in body_[0]:
            continue          # a gate or facade law: a call of the law it restates
        if kind == 'law':
            dl_ = lines[j]
            pn = [x.strip() for x in dl_[dl_.index('(') + 1:balanced(dl_, dl_.index('('))].split(',') if x.strip()]
            fors = [l for l in lines[i + 1:j] if l.startswith('  for ')]
        else:
            sg = ' '.join(l.strip() for l in lines[i:j + 1])
            op = sg.index('(')
            params = split_top(sg[op + 1:balanced(sg, op)])
            pn = [(re.match(r'^[+\-]?(\w+)', q) or re.match(r'(.*)', q)).group(1) for q in params]
            fors = params
        if not mentions_any(pn, [buf, size]):
            continue          # closed: an encoding and its size, evaluated
        none = 'None{}' in rhs.replace(' ', '') and 'Some{' not in rhs
        varbuf = bool(re.fullmatch(r'\w+', buf))
        if varbuf:
            if not none:
                raise ValueError(f'decode_window: {name}: a result that decodes over a free buffer {buf} needs a premise')
            if mentions(buf, [f for f in fors if not re.match(rf'\s*(for )?\+?{buf}:', f)]):
                raise ValueError(f'decode_window: {name}: a hypothesis mentions the free buffer {buf}')
        else:
            m = re.match(r'^(B\.Buf\{|[\w.]+\()', buf)
            args = None
            if m:
                op = len(m.group(1)) - 1
                try:
                    cl = balanced(buf, op)
                except ValueError:
                    cl = -1
                if cl == len(buf) - 1:
                    args = split_top(buf[op + 1:cl])
            if not args or args[-1] != size:
                raise ValueError(f'decode_window: {name}: the window {size} is not the size field of {buf}')
        recs[name] = dict(kind=kind, i=i, j=j, k=k, alias=alias, X=X, buf=buf, size=size, rhs=rhs, none=none, varbuf=varbuf, pn=pn)
    return recs


def wrap(text, names):
    """`text` with the laws that state a result of X_decode over a symbolic window moved to `NAME_in` (the proof, about the decoder
    of a window inside the buffer; the laws it calls are called as `_in` too) and carried to `X_decode` by the lemma of the decoder's
    window module. `names`: {X: file name of its decoder} (the runtime index)."""
    if '_decode(' not in text or '# decode window' in text:
        return text
    lines = text.split('\n')
    spans = list(block_spans(lines))
    recs = classify(lines, spans, names)
    if not recs:
        return text
    callee = re.compile(r'(?<![\w.])(' + '|'.join(sorted(recs, key=len, reverse=True)) + r')\(')
    out, used, last = [], set(), 0
    for kind, i, j, k, name in spans:
        r = recs.get(name)
        if r is None:
            continue
        out.extend(lines[last:i])
        last = k
        alias, X, buf, size, rhs, pn = r['alias'], r['X'], r['buf'], r['size'], r['rhs'], r['pn']
        dw = f'DW_{names[X]}'
        used.add(names[X])
        lam = 'b_'
        if r['varbuf']:
            inner = ', '.join(lam if a == buf else a for a in pn)
            proof = f'  {dw}.{X}_win_none_f({buf}, {size}, {lam} => {name}_in({inner}))'
        elif r['none']:
            proof = f'  {dw}.{X}_win_none({buf}, {size}, {name}_in({", ".join(pn)}))'
        else:
            proof = f'  {dw}.{X}_win_some({buf}, {size}, {rhs}, DWL.le_refl({size}), {name}_in({", ".join(pn)}))'
        body = [callee.sub(lambda m: m.group(1) + '_in(', l) for l in lines[j + 1:k]]
        out.append('# decode window: the proof is on the decoder of a window inside the buffer')
        if kind == 'law':
            fors = list(lines[i + 1:next(x for x in range(i + 1, j) if lines[x].startswith('  {'))])
            s0 = i + 1 + len(fors)
            sl = lines[s0:j]
            sl_in = [l.replace(f'{alias}.{X}_decode(', f'{alias}.{X}_decode_in(', 1) if x == 0 else l for x, l in enumerate(sl)]
            dline = lines[j]
            out.append(f'law {name}_in:')
            out.extend(fors)
            out.extend(sl_in)
            op = dline.index('(')
            cl = balanced(dline, op)
            head, rest = dline[:cl + 1], dline[cl + 1:]
            out.append(head.replace(f'def {name}(', f'def {name}_in(', 1) + callee.sub(lambda m: m.group(1) + '_in(', rest))
            out.extend(body)
            out.append('')
            out.append(f'law {name}:')
            out.extend(fors)
            out.extend(sl)
            out.append(f'def {name}({", ".join(pn)}):')
            out.append(proof)
        else:
            header = lines[i:j + 1]
            h2 = [l.replace(f'def {name}(', f'def {name}_in(', 1) if x == 0 else l for x, l in enumerate(header)]
            h2 = [l.replace(f'{alias}.{X}_decode(', f'{alias}.{X}_decode_in(', 1) for l in h2]
            out.extend(h2)
            out.extend(body)
            out.append('')
            out.extend(header)
            out.append(proof)
    out.extend(lines[last:])
    new = '\n'.join(out)
    m = IMPORT.search(new)
    prefix = m.group(1) if m else '../../'
    imps = [f'import {prefix}proofs/obj/decode_window_library_generated.bend as DWL'] + \
           [f'import {prefix}proofs/obj/decode_window_{f}_generated.bend as DW_{f}' for f in sorted(used)]
    ls = new.split('\n')
    at = max(i for i, l in enumerate(ls) if l.startswith('import ')) + 1
    return '\n'.join(ls[:at] + imps + ls[at:])
