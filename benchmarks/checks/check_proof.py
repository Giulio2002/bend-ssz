"""Check one Bend proof file with the pinned checker, one checker at a time.

    python3 benchmarks/checks/check_proof.py proofs/compact/word.bend [cap_bytes]

Records the macOS physical footprint peak (which includes compressed memory),
the elapsed time and the checker's real exit code, and says whether the output
contains "All terms check." with zero unsafe annotations. The full checker
output goes to build/proofcheck/<name>.log; a one-line summary is appended to
build/proofcheck/summary.log and printed. A lock file refuses a second
concurrent checker. Proof time and memory are uncapped by explicit operator instruction.
Legacy cap_bytes arguments are ignored; footprint and elapsed time remain recorded. The exit status of this script is 0 only for a real pass.
"""
import ctypes, fcntl, hashlib, json, os, re, signal, struct, subprocess, sys, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BEND = '/Users/monkeair/.bend/bin/bend'
OUT = ROOT / 'build/proofcheck'
LIB = ctypes.CDLL('/usr/lib/libproc.dylib')


def footprint(pid):
    buf = ctypes.create_string_buffer(1024)
    if LIB.proc_pid_rusage(pid, 4, ctypes.byref(buf)) != 0:
        return 0
    return struct.unpack_from('Q', buf.raw, 72)[0]


def pinned():
    """The checker and Base must be the pinned ones (benchmarks/toolchain.json);
    `bend update` replaces both in place, which once went unnoticed."""
    pin = json.loads((ROOT / 'benchmarks/toolchain.json').read_text())
    for part in ('bend', 'base'):
        got = hashlib.sha256(Path(pin[part]['path']).read_bytes()).hexdigest()
        if got != pin[part]['sha256']:
            return f'{pin[part]["path"]} has sha256 {got}, pinned {pin[part]["sha256"]}'
    return None


def main():
    target = sys.argv[1]
    bad = pinned()
    if bad:
        print('refusing to check with an unpinned toolchain: ' + bad)
        return 4
    cap = float("inf")  # User override: proof memory is uncapped, including legacy arguments.
    OUT.mkdir(parents=True, exist_ok=True)
    lock = open(OUT / '.lock', 'w')
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        print('another proof check is running; refusing to start a second one')
        return 3
    name = target.replace('/', '_').removesuffix('.bend')
    log = OUT / (name + '.log')
    started = time.monotonic()
    # The checker is a Bun program; this JavaScriptCore heap hint makes its
    # collector keep up (PROOF.bend peaked at 5.80 GB unset, 4.24 GB and ~30 %
    # faster at 3,000,000,000). Host configuration only; recorded in every
    # summary line.
    env = {**os.environ, 'BEND_NO_TELEMETRY': '1',
           'BUN_JSC_forceRAMSize': os.environ.get('BUN_JSC_forceRAMSize', '3000000000')}
    with open(log, 'w') as out:
        p = subprocess.Popen([BEND, target], cwd=ROOT, env=env, stdout=out, stderr=subprocess.STDOUT)
        peak, killed = 0, False
        while p.poll() is None:
            peak = max(peak, footprint(p.pid))
            if peak >= cap:
                p.send_signal(signal.SIGKILL)
                killed = True
                p.wait()
                break
            time.sleep(0.05)
    elapsed = time.monotonic() - started
    text = log.read_text(errors='replace')
    checked = 'All terms check' in text
    unsafe = re.search(r'\b[1-9][0-9]* unsafe annotations?\b|@unsafe', text) is not None
    ok = p.returncode == 0 and checked and not unsafe and not killed
    line = (f'{time.strftime("%Y-%m-%d %H:%M:%S")} {target} exit={p.returncode} '
            f'peak={peak / 1e9:.2f}GB elapsed={elapsed:.1f}s all_terms_check={checked} '
            f'unsafe={unsafe} killed={killed} heap_hint={env["BUN_JSC_forceRAMSize"]} '
            f'-> {"PASS" if ok else "FAIL"}')
    with open(OUT / 'summary.log', 'a') as s:
        s.write(line + '\n')
    print(line)
    if not ok:
        print(text[-6000:])
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
