"""Run a bend compile under a self-imposed memory cap, well below the watchdog."""
import ctypes, os, signal, struct, subprocess, sys, time
LIB = ctypes.CDLL('/usr/lib/libproc.dylib')
def footprint(pid):
    buf = ctypes.create_string_buffer(1024)
    if LIB.proc_pid_rusage(pid, 4, ctypes.byref(buf)) != 0: return 0
    return struct.unpack_from('Q', buf.raw, 72)[0]
src, out, cap = sys.argv[1], sys.argv[2], float(sys.argv[3])
# An output of '-' checks and runs the program in the interpreter instead.
cmd = ['/Users/monkeair/.bend/bin/bend', src] + ([] if out == '-' else ['-o', out])
# Compiler processes only: the JavaScriptCore heap hint the runners use
# (benchmarks/run.py, native_bench/run.py); the emitted C is unchanged by it.
env = {**os.environ, 'BEND_NO_TELEMETRY': '1', 'BUN_JSC_forceRAMSize': os.environ.get('HINT', '3000000000')}
p = subprocess.Popen(cmd, env=env,
                     stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
peak = 0
while p.poll() is None:
    peak = max(peak, footprint(p.pid))
    if peak >= cap:
        p.send_signal(signal.SIGKILL)
        print('OVER %.2f GB' % (peak / 1e9)); sys.exit(2)
    time.sleep(0.02)
print('exit=%d peak=%.2f GB' % (p.returncode, peak / 1e9))
lines = p.stdout.readlines()
if p.returncode or out == '-':
    print(''.join(lines[-40:]))
