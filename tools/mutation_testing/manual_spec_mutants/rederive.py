#!/usr/bin/env python3
"""Re-derive the manual spec-mutant patches that no longer apply to the generated text.

    python3 tools/mutation_testing/manual_spec_mutants/rederive.py [--write] [--redo] [--report FILE] [PATCH ...]

A patch (patches/<family>/<nn>.patch) is a header of `# key: value` lines and one or more unified-diff hunks (`-` lines, `+` lines, one context
line) on one file. After a change of the generated text (a renamed getter, a rewritten guard) the old hunk's context or its removed line is no
longer in the file, so `patch -p1` refuses it. The fault itself is a small textual replacement (a constant, an operator, an index): this script
re-derives it from the old patch instead of rewriting every patch by hand.

For each patch that does not apply to the current tree:
  1. the removed and added lines of every hunk are paired and compared token by token (words and single characters): each differing run is one
     replacement `old -> new` with the tokens around it as context;
  2. the replacement is searched in the current file: the context shrinks (6 tokens, 4, 3, 2, 1, none) until exactly one place matches, looking first
     inside the definitions named in the header's `# sym:` line, then in the whole file;
  3. every replacement of the patch must find exactly one place and the result must differ from the file; the new hunks are written with one context line,
     the header is kept, and a `# re-derived against <commit>` line is added.
A patch whose replacement finds no place or several is NOT written: it is listed (in the report) with the reason, to be redone by hand or retired.

Without --write nothing is changed (the report says what would be). Exit status 0 when every stale patch was re-derived, 1 otherwise.
"""
import difflib
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
PATCHES = ROOT / 'tools/mutation_testing/manual_spec_mutants/patches'
TOKEN = re.compile(r'\w+|\W')
CONTEXTS = (6, 4, 3, 2, 1, 0)


def parse(text):
    """(header lines, file path, [(removed, added)])"""
    lines = text.split('\n')
    head = []
    i = 0
    while i < len(lines) and lines[i].startswith('# '):
        head.append(lines[i])
        i += 1
    path = None
    pairs = []
    rem, add = [], []

    def flush():
        nonlocal rem, add
        if rem or add:
            pairs.append((rem, add))
        rem, add = [], []
    for ln in lines[i:]:
        if ln.startswith('--- a/'):
            path = ln[len('--- a/'):]
        elif ln.startswith('+++ b/') or ln.startswith('@@'):
            flush()
        elif ln.startswith('-'):
            rem.append(ln[1:])
        elif ln.startswith('+'):
            add.append(ln[1:])
        else:
            flush()
    flush()
    return head, path, pairs


def applies(patch):
    r = subprocess.run(['patch', '-p1', '--dry-run', '-s'], input=patch.read_text(), text=True, cwd=ROOT, capture_output=True)
    return r.returncode == 0


def replacements(old_line, new_line):
    """[(left, old, new, right)] token runs that differ between the two lines"""
    a, b = TOKEN.findall(old_line), TOKEN.findall(new_line)
    out = []
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes():
        if tag != 'equal':
            out.append((a[:i1], ''.join(a[i1:i2]), ''.join(b[j1:j2]), a[i2:]))
    return out


def blocks_of(lines, names, prefix=False):
    """line indexes inside the definitions named in `names`"""
    keep = set()
    cur = False
    for k, ln in enumerate(lines):
        m = re.match(r'def (\w+)\(', ln)
        if m:
            cur = any(m.group(1) == n or (prefix and m.group(1).startswith(n + '_')) for n in names)
        elif ln and not ln.startswith((' ', '\t')):
            cur = False
        if cur:
            keep.add(k)
    return keep


def find(lines, left, old, right, names):
    """the unique (line index, character offset) of `left old right` (the context shrinks until it is unique), or the reason it is not"""
    inside = blocks_of(lines, names) if names else set()
    near = blocks_of(lines, names, True) if names else set()
    why = 'no place'
    for scope in [s for s in (inside, near, set(range(len(lines)))) if s]:
        for n in CONTEXTS:
            lc = ''.join(left[-n:]) if n else ''
            rc = ''.join(right[:n]) if n else ''
            needle = lc + old + rc
            if not needle.strip():
                continue
            hits = [(k, m.start() + len(lc)) for k in sorted(scope) for m in re.finditer(re.escape(needle), lines[k])]
            if len(hits) == 1:
                return hits[0], None
            if len(hits) > 1:
                why = f'{len(hits)} places for `{needle}`'
            elif n == CONTEXTS[-1]:
                why = f'no place for `{old}`' if why == 'no place' else why
    return None, why


def aligned(lines, old_line, new_line, names):
    """fallback for a hunk whose context is gone: the line of the file most like the removed line (unique, within the `# sym:` definitions first),
    with the replacement placed by aligning the tokens of the two lines; (line index, new text) or the reason"""
    scopes = [s for s in (blocks_of(lines, names), blocks_of(lines, names, True), set(range(len(lines)))) if s]
    a = TOKEN.findall(old_line)
    reps = [(len(left), len(TOKEN.findall(old)), new) for left, old, new, right in replacements(old_line, new_line)]
    for scope in scopes:
        scored = sorted(((difflib.SequenceMatcher(None, a, TOKEN.findall(lines[k]), autojunk=False).ratio(), k) for k in scope if lines[k].strip()), reverse=True)[:2]
        if not scored or scored[0][0] < 0.6 or (len(scored) > 1 and scored[0][0] - scored[1][0] < 0.03):
            continue
        k = scored[0][1]
        c = TOKEN.findall(lines[k])
        blocks = difflib.SequenceMatcher(None, a, c, autojunk=False).get_matching_blocks()
        out = list(c)
        for i1, n, new in sorted(reps, reverse=True):
            for ai, ci, size in blocks:
                if ai <= i1 and i1 + n <= ai + size and (n or i1 < ai + size):
                    j = ci + (i1 - ai)
                    out[j:j + n] = [new]
                    break
            else:
                return None, f'the replaced tokens of `{old_line.strip()[:60]}` are in text that changed'
        return (k, ''.join(out)), None
    return None, 'no line of the file is like the removed line'


def tr(line):
    """an old line read in the NMAX regime (docs/SIZE_LIMIT_DESIGN.md): the decode cap, then the marker"""
    line = line.replace('U32.is_lt(size, 2147483648)', 'U32.is_le(size, 4294967264)')
    return re.sub(r'\b2147483648\b', '4294967295', line)


def rederive(patch, commit, translate=False):
    head, path, pairs = parse(patch.read_text())
    if translate:      # the size-limit change: the marker 2^31 became 2^32 - 1 and the decode cap `size < 2^31` became `size <= NMAX`
        pairs = [([tr(x) for x in rem], [tr(x) for x in add]) for rem, add in pairs]
    target = ROOT / path
    if not target.exists():
        return None, f'the file {path} is gone'
    lines = target.read_text().split('\n')
    names = set()
    for h in head:
        m = re.match(r'# sym: (.*)', h)
        if m:
            names = {s.strip() for s in m.group(1).split(',') if s.strip()}
    edits = []
    line_edits = {}
    for rem, add in pairs:
        old_line = '\n'.join(rem)
        new_line = '\n'.join(add)
        if '\n' in old_line or '\n' in new_line:
            if len(rem) != len(add):
                return None, 'a hunk that changes the number of lines'
            reps = [r for a, b in zip(rem, add) for r in replacements(a, b)]
        else:
            reps = replacements(old_line, new_line)
        if not reps:
            return None, 'a hunk without a textual replacement'
        found, reason = [], None
        for left, old, new, right in reps:
            place, why = find(lines, left, old, right, names)
            if place is None:
                reason = why
                break
            found.append((place, old, new))
        if reason is None:
            edits.extend(found)
        elif len(rem) == 1 and len(add) == 1:
            got, why = aligned(lines, rem[0], add[0], names)
            if got is None:
                return None, f'{reason}; {why}'
            line_edits[got[0]] = got[1]
        else:
            return None, reason
    new_lines = list(lines)
    for (k, off), old, new in sorted(edits, key=lambda e: (e[0][0], -e[0][1])):
        ln = new_lines[k]
        if ln[off:off + len(old)] != old:
            return None, 'overlapping replacements'
        new_lines[k] = ln[:off] + new + ln[off + len(old):]
    for k, text in line_edits.items():
        new_lines[k] = text
    if new_lines == lines:
        return None, 'the replacement changes nothing'
    diff = list(difflib.unified_diff(lines, new_lines, f'a/{path}', f'b/{path}', n=1, lineterm=''))
    old = patch.read_text().split("\n")
    shape = lambda d: (sum(1 for x in d if x.startswith("-") and not x.startswith("---")), sum(1 for x in d if x.startswith("@@")))    # noqa: E731
    if shape(diff) != shape(old):
        # the same fault touches as many lines in as many hunks; another count is another fault (round 7 G2: a second `case False` was made)
        return None, f"the re-derived patch changes {shape(diff)[0]} lines in {shape(diff)[1]} hunks, the original {shape(old)[0]} in {shape(old)[1]}"
    head = [h for h in head if not h.startswith('# re-derived')] + [f'# re-derived against {commit}']
    return '\n'.join(head + diff) + '\n', None


# Faults whose line no longer exists in the changed text (crash-fix 3 moved the guards into `*_app_c`, `*_app_sz`, `*_capp_sz`, `*_app_w`, and the root clamps
# into `cap_cnt` calls): the same fault written against the new line. id -> (file, scope definitions (and their `_`-suffixed helpers), [(old, new)]); each `old` must
# be unique in the scope.
OVERRIDES = {
    'r2-a02-large-limit-append/02': ('types/Fulu_list_uint8_1099511627776_def_generated.bend', ['l1099511627776_u8_app_c'],
                                     [('U32.is_lt(n, 4294967264)', 'U32.is_lt(n, 4294967263)')]),
    'r2-a06-cells/04': ('types/Fulu_list_bytevec_2048_4096_def_generated.bend', ['l4096_b2048_app_w'], [('U32.is_lt(n, 4096)', 'U32.is_lt(n, 4095)')]),
    'r2-a06-cells/06': ('types/Fulu_list_bytevec_2048_4096_def_generated.bend', ['l4096_b2048_app_w'],
                        [('Bool.and(Bool.and(Bool.and(U32.is_lt(n, 4096), ', 'Bool.and(Bool.and(U32.is_lt(n, 4096), '), ('sc)), U32.is_eq(vn, 2048)), U32.is_le(512, vc))', 'sc)), U32.is_le(512, vc))')]),
    'r2-a06-cells/07': ('types/Fulu_list_bytevec_2048_4096_def_generated.bend', ['l4096_b2048_app_w'], [('U32.is_eq(vn, 2048)', 'U32.is_le(vn, 2048)')]),
    'r2-h04-element-chunks/05': ('src/obj.bend', ['er_size'], [('(4 * ew : U32)', '(4 * ew + 4 : U32)')]),
    'r2-k01-cap-cnt/10': ('src/obj.bend', ['wrp_slow', 'wrp_cap', 'wrp_fit'], [('cap_cnt(chunks_of(n), e8(chunks_of(n)), 8n, U32.to_nat(sz))', 'chunks_of(n)')]),
    'r3-g01-append-guard/10': ('types/Fulu_list_Validator_1099511627776_def_generated.bend', ['l1099511627776_Validator_app_sz'], [('U32.is_lt(n, 17747798)', 'U32.is_le(n, 17747798)')]),
    'r3-g01-append-guard/12': ('types/proglist_SmallTestStruct_def_generated.bend', ['pl_SmallTestStruct_app_sz'], [('U32.is_lt(n, 1073741816)', 'U32.is_le(n, 1073741816)')]),
    'r3-g01-append-guard/15': ('types/Fulu_list_ProposerSlashing_16_def_generated.bend', ['l16_ProposerSlashing_app_sz'], [('U32.is_lt(n, 16)', 'U32.is_le(n, 16)')]),
    # round 7 G2: re-derivations that applied but made another fault (a constant of another definition, an always-true test, a cap on a name where it
    # cannot be observed), written by hand
    'r2-d01-decode-checked/04': ('types/FuluCheckpoint_decode_ssz_generated.bend', ['Checkpoint_dchw'], [('U32.is_le(size, 4294967264)', 'U32.is_le(size, 4294967265)')]),
    'r2-d01-decode-checked/06': ('types/proglist_uint8_decode_ssz_generated.bend', ['proglist_uint8_dchw'], [('U32.is_le(size, 4294967264)', 'U32.is_lt(size, 4294967264)')]),
    'r2-d01-decode-checked/10': ('types/VarTestStruct_decode_ssz_generated.bend', ['VarTestStruct_dchw'], [('U32.is_le(size, 4294967264)', 'U32.is_le(size, 4294967265)')]),
    'r7-g1-cap-reversion/01': ('types/proglist_uint8_decode_ssz_generated.bend', ['proglist_uint8_dchw'], [('U32.is_le(size, 4294967264)', 'U32.is_lt(size, 2147483648)')]),
    'r3-p05-fulu-field-validity/10': ('types/Fulu_list_uint8_1099511627776_encode_ssz_generated.bend', ['l1099511627776_u8_valid'],
                                      [('O.words_ok(o, 0, 4294967264, False{}, 1)', 'O.words_ok(o, 0, 4294967294, False{}, 1)')]),
    'r2-s05-poison/03': ('src/obj.bend', ['pz'], [('case False{}: 4294967295', 'case False{}: 1073741824')]),
    'r3-l02-variable-elements/01': ('types/Fulu_list_AttesterSlashing_1_encode_ssz_generated.bend', ['l1_AttesterSlashing_sz_fin'], [('O.padd(O.mul4c(n), m)', 'O.padd(0, m)')]),
    'c05-offset-encode/09': ('src/obj.bend', ['padd'], [('), (a + b : U32), 4294967295)', '), (a + b + 1 : U32), 4294967295)')]),
}


def from_override(patch, commit):
    key = f'{patch.parent.name}/{patch.stem}'
    if key not in OVERRIDES:
        return None, None
    path, scope, subs = OVERRIDES[key]
    head, _, _ = parse(patch.read_text())
    lines = (ROOT / path).read_text().split('\n')
    inside = blocks_of(lines, set(scope), True)
    new_lines = list(lines)
    for old, new in subs:
        hits = [k for k in sorted(inside) if old in new_lines[k]]
        if len(hits) != 1:
            return None, f'override: {len(hits)} lines hold `{old[:50]}` in {scope}'
        new_lines[hits[0]] = new_lines[hits[0]].replace(old, new)
    head = [h for h in head if not h.startswith(('# re-derived', '# file:'))] + [f'# file: {path}', f'# re-derived against {commit} (by hand: the guard moved)']
    diff = list(difflib.unified_diff(lines, new_lines, f'a/{path}', f'b/{path}', n=1, lineterm=''))
    return '\n'.join(head + diff) + '\n', None


def main():
    write = '--write' in sys.argv
    redo = '--redo' in sys.argv      # the patches with an override are rewritten from it even when they apply (a re-derivation that made another fault)
    report = None
    args = [a for a in sys.argv[1:] if a not in ('--write', '--redo')]
    if '--report' in args:
        i = args.index('--report')
        report = pathlib.Path(args[i + 1])
        del args[i:i + 2]
    commit = subprocess.run(['git', 'rev-parse', '--short', 'HEAD'], cwd=ROOT, capture_output=True, text=True).stdout.strip()
    todo = [pathlib.Path(a) for a in args] or sorted(PATCHES.glob('*/*.patch'))
    done, failed, fine = [], [], 0
    for p in todo:
        if applies(p) and not (redo and f'{p.parent.name}/{p.stem}' in OVERRIDES):
            fine += 1
            continue
        new, why = from_override(p, commit)
        if new is None and why is None:
            new, why = rederive(p, commit)
            if new is None:
                alt, why2 = rederive(p, commit, True)
                if alt is not None:
                    new, why = alt.replace(f"# re-derived against {commit}", f"# re-derived against {commit} (the 2^31 marker / cap read as 2^32 - 1 / NMAX)"), None
        if new is None:
            failed.append((p, why))
            continue
        if write:
            p.write_text(new)
            if not applies(p):
                failed.append((p, 'the re-derived patch does not apply'))
                continue
        done.append(p)
    print(f'{fine} apply, {len(done)} re-derived{"" if write else " (dry run)"}, {len(failed)} cannot be re-derived')
    lines = ['# Mutant patches that could not be re-derived', '',
             f'`rederive.py` against {commit}: {fine} patches apply as they are, {len(done)} were re-derived, {len(failed)} cannot be.', '',
             '| patch | reason |', '|---|---|']
    for p, why in failed:
        lines.append(f'| `{p.relative_to(PATCHES)}` | {why} |')
    if report:
        report.write_text('\n'.join(lines) + '\n')
    for p, why in failed:
        print(f'  {p.relative_to(PATCHES)}: {why}')
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
