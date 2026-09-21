"""Check one Bend proof file with the pinned checker, one checker at a time.

    python3 benchmarks/checks/check_proof.py proofs/compact/word.bend [cap_bytes]

Records the macOS physical footprint peak (which includes compressed memory),
the elapsed time and the checker's real exit code, and says whether the output
contains "All terms check." with zero unsafe annotations. The full checker
output goes to build/proofcheck/<name>.log; a one-line summary is appended to
build/proofcheck/summary.log and printed. A lock file refuses a second
concurrent checker. The process is killed when the footprint reaches the cap
(default 6.5 GB), well below the 8 GB proof ceiling; a killed check is a failed
check. The exit status of this script is 0 only for a real pass.
"""
import ctypes, fcntl, os, re, signal, struct, subprocess, sys, time
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


def main():
    target = sys.argv[1]
    cap = float(sys.argv[2]) if len(sys.argv) > 2 else 6.5e9
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
    env = {**os.environ, 'BEND_NO_TELEMETRY': '1'}
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
            f'unsafe={unsafe} killed={killed} -> {"PASS" if ok else "FAIL"}')
    with open(OUT / 'summary.log', 'a') as s:
        s.write(line + '\n')
    print(line)
    if not ok:
        print(text[-6000:])
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
