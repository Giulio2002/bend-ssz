"""Frozen byte-alias identity/bounds; no SSZ algorithms or fixture outputs."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
schemas=json.loads((ROOT/'schemas/fulu_mainnet.json').read_text())
entries=[(name,s['length']) for name,s in schemas.items() if s['kind']=='bytes']
lines=['import Base\n', '# Closed identities and exact frozen mainnet lengths, shared representation metadata.', 'type ByteAlias is Data:']
lines += [f'  {name}{{}}' for name,n in entries]
lines += ['', 'def size(alias: ByteAlias) -> Nat:', '  match alias:']
for name,n in entries:
    bound=f'Nat.mul({n//1024}n, 1024n)' if n>=1024 else f'{n}n'
    lines.append(f'    case {name}{{}}: {bound}')
(ROOT/'types/byte_alias.bend').write_text('\n'.join(lines)+'\n')
