#!/usr/bin/env python3
"""Check Bend proof modules one at a time and record what each one costs.

The operator's restart requires proof checking to stay under 8,000,000,000
bytes of macOS *physical footprint* (which counts compressed and swapped
pages; RSS alone hid a ~49 GB excursion), with a 7 GB watchdog, and with only
one checker running at a time. This runner exists so that every proof-check in
this workspace is measured the same way:

  * exactly one `bend` process at a time, started by this script;
  * peak physical footprint sampled from proc_pid_rusage (the same field the
    operator's watchdog uses), not RSS;
  * the checker's real exit status and full output, never a pipeline whose
    exit code belongs to `grep`;
  * a self-imposed stop threshold below the watchdog's, so an exploding module
    is reported as a failure here instead of being killed by the watchdog.

    python3 tools/generate_proof_memory_report.py PROOF.bend proofs/foo.bend
    python3 tools/generate_proof_memory_report.py --all
    python3 tools/generate_proof_memory_report.py --stop-bytes 4e9 ROOT_DOMAIN.bend

Writes build/proof-memory.json (accumulated, keyed by file) and prints one
line per module. A module that is killed for memory is recorded with
status="over_budget" and is a FAILURE, never a pass.
"""
from __future__ import annotations

import argparse
import ctypes
import datetime
import json
import os
import signal
import struct
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BEND = Path(os.environ.get("BEND_BIN") or Path.home() / ".bend/bin/bend")
REPORT = ROOT / "build" / "proof-memory.json"
WATCHDOG_STOP = 7_000_000_000
DEFAULT_STOP = 6_000_000_000

_LIB = ctypes.CDLL("/usr/lib/libproc.dylib")


def footprint(pid: int) -> int | None:
    """macOS physical footprint of `pid`, including compressed pages."""
    buf = ctypes.create_string_buffer(1024)
    if _LIB.proc_pid_rusage(pid, 4, ctypes.byref(buf)) != 0:
        return None
    return struct.unpack_from("Q", buf.raw, 72)[0]


def others_running() -> list[str]:
    """Other SSZ bend checkers already running; the watchdog kills the second one.

    The watchdog only counts checks (no -c/-r/-o) whose cwd is under the SSZ
    runs root, so compilations and other projects are not conflicts here
    either.
    """
    out = subprocess.run(["ps", "-axo", "pid=,command="], text=True, capture_output=True).stdout
    found = []
    for line in out.splitlines():
        parts = line.strip().split(None, 1)
        if len(parts) != 2:
            continue
        pid, command = parts
        if not command.startswith(f"{BEND} ") or int(pid) == os.getpid():
            continue
        if any(flag in command.split() for flag in ["-c", "-r", "-o", "--help", "--version"]):
            continue
        ls = subprocess.run(["lsof", "-a", "-p", pid, "-d", "cwd", "-Fn"], text=True, capture_output=True)
        cwd = next((x[1:] for x in ls.stdout.splitlines() if x.startswith("n/")), "")
        if cwd.startswith("/Users/monkeair/work/ssz-optimization/runs"):
            found.append(f"{pid} {command}")
    return found


def check(path: Path, stop_bytes: int, timeout: float) -> dict:
    started = time.time()
    env = dict(os.environ, BEND_NO_TELEMETRY="1")
    logs = ROOT / "build" / "proof-memory-logs"
    logs.mkdir(parents=True, exist_ok=True)
    log_path = logs / (str(path).replace("/", "_") + f".{time.time_ns()}.log")
    output_log = log_path.open("w+")
    proc = subprocess.Popen(
        [str(BEND), str(path)],
        cwd=str(ROOT),
        env=env,
        stdout=output_log,
        stderr=subprocess.STDOUT,
        text=True,
    )
    peak = 0
    killed = None
    trace: list[list[float]] = []
    while proc.poll() is None:
        current = footprint(proc.pid)
        if current is not None:
            peak = max(peak, current)
            trace.append([round(time.time() - started, 2), current])
            if current >= stop_bytes:
                killed = "over_budget"
                proc.send_signal(signal.SIGKILL)
                break
        if time.time() - started > timeout:
            killed = "timeout"
            proc.send_signal(signal.SIGKILL)
            break
        time.sleep(0.05)
    code = proc.wait()
    output_log.seek(0)
    output = output_log.read()
    output_log.close()
    elapsed = time.time() - started
    # The footprint-over-time trace separates a steady climb (retained law
    # statements accumulating across imports) from a late spike (one module's
    # transient proof bodies), which decides where a fix has to go.
    trace_path = logs / (log_path.name + ".trace.json")
    trace_path.write_text(json.dumps(trace) + "\n")
    ok = killed is None and code == 0 and "ALL PROOFS CHECK" in output
    return {
        "file": str(path),
        "status": killed or ("pass" if ok else "fail"),
        "exit_code": code,
        "peak_footprint_bytes": peak,
        "elapsed_seconds": round(elapsed, 2),
        "all_terms_check": "ALL PROOFS CHECK" in output,
        "output_tail": output[-4000:],
        "output_log": str(log_path),
        "at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "stop_bytes": stop_bytes,
        "trace": str(trace_path),
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="*")
    ap.add_argument("--all", action="store_true", help="every proofs/*.bend plus the three roots")
    ap.add_argument("--stop-bytes", type=float, default=DEFAULT_STOP)
    ap.add_argument("--timeout", type=float, default=7200.0)
    ap.add_argument("--quiet-output", action="store_true")
    args = ap.parse_args()

    stop = int(args.stop_bytes)
    if stop >= WATCHDOG_STOP:
        print(f"refusing stop-bytes {stop} >= watchdog {WATCHDOG_STOP}", file=sys.stderr)
        return 2

    targets = [Path(f) for f in args.files]
    if args.all:
        targets = sorted(Path("proofs").glob("*.bend")) + [
            Path("HASH_PROOF.bend"),
            Path("END_TO_END.bend"),
            Path("ROOT_DOMAIN.bend"),
            Path("PROOF.bend"),
        ]
    if not targets:
        ap.error("no files")

    busy = others_running()
    if busy:
        print("another bend checker is running; refusing to start a second:", file=sys.stderr)
        for line in busy:
            print("  " + line, file=sys.stderr)
        return 2

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    report = {}
    if REPORT.exists():
        report = json.loads(REPORT.read_text())

    failures = 0
    for path in targets:
        result = check(path, stop, args.timeout)
        report[str(path)] = result
        REPORT.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
        mb = result["peak_footprint_bytes"] / 1e6
        print(
            f"{result['status']:>11}  {mb:9.1f} MB  {result['elapsed_seconds']:8.1f}s  "
            f"exit={result['exit_code']}  {path}",
            flush=True,
        )
        if result["status"] != "pass":
            failures += 1
            if not args.quiet_output:
                print(result["output_tail"][-2000:], flush=True)
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
