#!/usr/bin/env python3
"""Split one type's encode into its parts, on a real decoded fixture.

    python3 benchmarks/probes/enc_split.py ExecutionPayloadHeader [fixture.ssz] [ops]

Writes build/probes/enc_split_<T>.bend from the same template as
benchmarks/probes/enc_parts.bend (size / whole encode / the output allocation /
putn into one reused buffer, every mode consuming a word of its result),
compiles it and prints ns per operation for each part.
"""
import os, pathlib, re, subprocess, sys
ROOT = pathlib.Path(__file__).resolve().parents[2]
T = sys.argv[1]
inp = sys.argv[2] if len(sys.argv) > 2 else str(ROOT / f'build/performance/inputs/{T}.medium-fixture.ssz')
ops = int(sys.argv[3]) if len(sys.argv) > 3 else 200000
src = (ROOT / 'benchmarks/probes/enc_parts.bend').read_text()
body = src[:src.index('# ---- BeaconBlock ----')] + src[src.index('# ---- reporting ----'):]
cut = body.index('def keep_block(')
body = body[:cut] + body[body.index('def keep_put(', cut):]
cut = body.index('def keep_bput(')
body = body[:cut] + body[body.index('def run_bsize(', cut):]
cut = body.index('def ploop84(')
body = body[:cut] + body[body.index('def run_ksize(', cut):]
cut = body.index('def run_ksize(')
body = body[:cut] + body[body.index('def body_run(', cut):]
body = re.sub(r"def block_run\(.*?(?=def with_body)", '', body, flags=re.S)
body = re.sub(r"def with_block\(.*?(?=def body_decoded)", '', body, flags=re.S)
body = re.sub(r"def block_decoded\(.*?(?=def start_at)", '', body, flags=re.S)
body = body.replace("""def body_run(+mode: U32, +ops: U32, o: T.BeaconBlockBody) -> IO(Unit):
  match mode:
    case 0: run_bsize(ops, o)
    case 1: run_benc(ops, o)
    case 2: run_balloc_at(ops, T.BeaconBlockBody_size(o))
    case 3: run_bput(ops, T.BeaconBlockBody_size(o))
    case _: run_bput84(ops, T.BeaconBlockBody_size(o))""", """def body_run(+mode: U32, +ops: U32, o: T.BeaconBlockBody) -> IO(Unit):
  match mode:
    case 0: run_bsize(ops, o)
    case 1: run_benc(ops, o)
    case 2: run_balloc_at(ops, T.BeaconBlockBody_size(o))
    case _: run_bput(ops, T.BeaconBlockBody_size(o))""")
body = re.sub(r"def start_at\(.*?(?=def main)", """def start(+mode: U32, +ops: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  body_decoded(mode, ops, T.BeaconBlockBody_decode(buf, size))

""", body, flags=re.S)
body = body.replace('BeaconBlockBody', T)
out = ROOT / f'build/probes/enc_split_{T}.bend'
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(body.replace('../../src/', '../../src/').replace('../compact/', '../../benchmarks/compact/'))
exe = out.with_suffix('')
env = {**os.environ, 'BUN_JSC_forceRAMSize': '3000000000'}
r = subprocess.run(['/Users/monkeair/.bend/bin/bend', str(out), '-o', str(exe)], env=env, capture_output=True, text=True)
if r.returncode:
    sys.exit(r.stdout + r.stderr)
for mode, label in [(0, 'size'), (1, 'encode'), (2, 'alloc'), (3, 'putn')]:
    best = None
    for _ in range(3):
        t = subprocess.run([str(exe), '--threads', '1', '--gpu', 'off'], capture_output=True, text=True,
                           env={**os.environ, 'SSZ_MODE': str(mode), 'SSZ_OPS': str(ops), 'SSZ_INPUT': inp})
        ms = int(re.search(r'MS=(\d+)', t.stdout).group(1))
        best = ms if best is None else min(best, ms)
    print(f'{T:28} {label:7} {best * 1e6 / ops:9.1f} ns')
