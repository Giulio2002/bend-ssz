"""dedupe_hook.py DEFS_DIR: (file, old, new) of every earlier def block (rounds 1-10: defs/*.txt not r11_*, plus r7/defs_budget), for mk8.py's duplicate check."""
import glob, os, re


def earlier(defs):
    seen = set()
    for f in sorted(glob.glob(os.path.join(defs, '*.txt')) + glob.glob(os.path.join(defs, '..', 'r7', 'defs_budget', '*.txt'))):
        if os.path.basename(f).startswith('r11_'):
            continue
        cur = None
        for line in open(f).read().split('\n') + ['=== end']:
            if line.startswith('==='):
                if cur and cur.get('file'):
                    seen.add((cur['file'], tuple(('\n'.join(h['old']), '\n'.join(h['new'])) for h in cur['hunks'])))
                cur = {'hunks': []}
                continue
            if cur is None or line.startswith('##'):
                continue
            if line[:1] == '-':
                if not cur['hunks'] or cur['hunks'][-1]['new']:
                    cur['hunks'].append({'old': [], 'new': []})
                cur['hunks'][-1]['old'].append(line[1:])
            elif line[:1] == '+' and cur['hunks']:
                cur['hunks'][-1]['new'].append(line[1:])
            elif re.match(r'^[a-z_]+:', line):
                k, v = line.split(':', 1)
                cur[k] = v.strip()
    return seen
