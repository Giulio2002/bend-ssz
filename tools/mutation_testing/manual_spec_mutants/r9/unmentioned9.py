import json, os, re, collections
tree = 'tree'
idx = json.load(open(os.path.join(tree, 'types/runtime_index.json')))
syms = idx['symbols']
# defs per types file
defs = {}
for f in os.listdir(os.path.join(tree, 'types')):
    if f.endswith('_generated.bend'):
        for m in re.finditer(r'^def (\w+)', open(os.path.join(tree, 'types', f)).read(), re.M):
            defs[m.group(1)] = f
seen = set()
tok = re.compile(r'[A-Za-z_][A-Za-z0-9_]*')
for top in ('proofs', 'e2e'):
    for d, ds, fs in os.walk(os.path.join(tree, top)):
        for f in fs:
            if f.endswith('.bend'):
                seen.update(tok.findall(open(os.path.join(d, f)).read()))
for f in ('END_TO_END.bend', 'PROOF.bend', 'HASH_PROOF.bend', 'ROOT_DOMAIN.bend'):
    p = os.path.join(tree, f)
    if os.path.exists(p): seen.update(tok.findall(open(p).read()))
API = re.compile(r'_(get_\w+|set_\w+|swap_\w+|append|take|ctake|cget|get|set|serialize|encode|decode|decode_checked|decode_checked_budget|ok|valid|hash_tree_root|default|build|read|cached_root|cache|uncache|cset|cappend)$')
un = collections.defaultdict(list)
cnt = collections.Counter()
for s, f in defs.items():
    if API.search(s):
        cnt['api'] += 1
        if s not in seen:
            un[f].append(s)
            cnt['un'] += 1
print(dict(cnt))
json.dump(un, open('unmentioned.json', 'w'), indent=0)
c = collections.Counter()
for f, l in un.items():
    for s in l:
        c[API.search(s).group(1).split('_')[0] if API.search(s).group(1).startswith(('get_','set_','swap_')) else API.search(s).group(1)] += 1
print(c.most_common())
