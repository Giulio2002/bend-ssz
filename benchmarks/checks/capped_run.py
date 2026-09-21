"""Run any command under a physical-footprint cap summed over its process
tree (macOS ri_phys_footprint), below the operator's 7 GB watchdog. Prints the
peak and the command's real exit code; a capped run exits 2 and is a failure."""
import ctypes, signal, struct, subprocess, sys, time
import psutil

LIB = ctypes.CDLL('/usr/lib/libproc.dylib')


def footprint(pid):
    buf = ctypes.create_string_buffer(1024)
    if LIB.proc_pid_rusage(pid, 4, ctypes.byref(buf)) != 0:
        return 0
    return struct.unpack_from('Q', buf.raw, 72)[0]


cap = float(sys.argv[1])
log = open(sys.argv[2], 'w')
cmd = sys.argv[3:]
started = time.monotonic()
p = subprocess.Popen(cmd, stdout=log, stderr=subprocess.STDOUT)
peak = 0
while p.poll() is None:
    try:
        tree = [p.pid] + [c.pid for c in psutil.Process(p.pid).children(recursive=True)]
    except psutil.Error:
        tree = [p.pid]
    peak = max(peak, sum(footprint(q) for q in tree))
    if peak >= cap:
        for q in reversed(tree):
            try:
                psutil.Process(q).send_signal(signal.SIGKILL)
            except psutil.Error:
                pass
        print('CAPPED peak=%.2f GB after %.0f s' % (peak / 1e9, time.monotonic() - started))
        sys.exit(2)
    time.sleep(0.05)
print('exit=%d peak=%.2f GB elapsed=%.0f s' % (p.returncode, peak / 1e9, time.monotonic() - started))
sys.exit(p.returncode)
