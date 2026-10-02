"""Read/write tracer for codegen/regenerate_touched.py (loaded as sitecustomize through PYTHONPATH, only when
REGEN_TRACE names a directory). Every python process of a traced generator run (the generator and any python
child it starts) appends a JSON file <REGEN_TRACE>/<pid>.json at exit:
  {"files": {relpath: sha256 or null}, "dirs": {relpath: sha256 of the sorted listing}, "changed": [written files
  whose content differs from before the write]}
of the files under REGEN_ROOT the process read or wrote and the directories it listed. A file's hash is taken
when the process first touched it, unless the process itself wrote, removed or renamed it (or, for a directory,
changed its entries): then it is taken at exit. So a concurrent writer that changes a file after this process
read it makes the recorded hash differ from the file's final content, and the generator is rerun (conservative).
Loaded modules (sys.modules) count as read files, since a cached .pyc hides the source open.
"""
import os
import sys

_D = os.environ.get('REGEN_TRACE')
if _D:
    import atexit
    import hashlib
    import json

    _R = os.path.realpath(os.environ['REGEN_ROOT'])
    _files, _dirs, _wrote, _wdirs = {}, {}, set(), set()
    _busy = [False]

    def _rel(p):
        try:
            p = os.path.realpath(p)
        except Exception:
            return None
        if not (p == _R or p.startswith(_R + os.sep)):
            return None
        r = os.path.relpath(p, _R)
        if r == 'build' or r.startswith('build' + os.sep) or '__pycache__' in r or r.startswith('.git' + os.sep):
            return None
        return r

    def _hash_file(r):
        try:
            with open(os.path.join(_R, r), 'rb') as f:
                return hashlib.sha256(f.read()).hexdigest()
        except (OSError, IsADirectoryError):
            return None

    def _hash_dir(r):
        try:
            return hashlib.sha256('\0'.join(sorted(x for x in os.listdir(os.path.join(_R, r)) if x != '__pycache__' and not (r == '.' and x in ('build', '.git')))).encode()).hexdigest()
        except OSError:
            return None

    def _hook(ev, args):
        if _busy[0]:
            return
        try:
            if ev == 'open':
                path, mode = args[0], args[1]
                if not isinstance(path, (str, bytes, os.PathLike)):
                    return
                _busy[0] = True
                try:
                    r = _rel(os.fsdecode(path))
                    if r is None:
                        return
                    m = mode if isinstance(mode, str) else ''
                    w = any(c in m for c in 'wax+') or (isinstance(args[2], int) and args[2] & (os.O_WRONLY | os.O_RDWR | os.O_CREAT | os.O_TRUNC))
                    if r not in _files:
                        _files[r] = _hash_file(r)
                    if w:
                        _wrote.add(r)
                        _wdirs.add(os.path.dirname(r))
                finally:
                    _busy[0] = False
            elif ev in ('os.listdir', 'os.scandir'):
                if args[0] is None:
                    p = '.'
                else:
                    p = args[0]
                if isinstance(p, int):
                    return
                _busy[0] = True
                try:
                    r = _rel(os.fsdecode(p))
                    if r is not None and r not in _dirs:
                        _dirs[r] = _hash_dir(r)
                finally:
                    _busy[0] = False
            elif ev in ('os.remove', 'os.rename', 'os.replace', 'shutil.copyfile', 'shutil.move'):
                _busy[0] = True
                try:
                    for a in args[:2]:
                        if isinstance(a, (str, bytes, os.PathLike)):
                            r = _rel(os.fsdecode(a))
                            if r is not None:
                                if ev in ('os.remove', 'os.rename', 'os.replace', 'shutil.move') or a is args[1]:
                                    _wrote.add(r)
                                    _wdirs.add(os.path.dirname(r))
                finally:
                    _busy[0] = False
        except Exception:
            _busy[0] = False

    def _fin():
        _busy[0] = True
        try:
            for m in list(sys.modules.values()):
                f = getattr(m, '__file__', None)
                if f:
                    r = _rel(f)
                    if r is not None and r not in _files:
                        _files[r] = _hash_file(r)
            changed = []
            for r in _wrote:
                pre = _files.get(r)
                _files[r] = _hash_file(r)
                if _files[r] != pre:
                    changed.append(r)
            for r in list(_dirs):
                if r in _wdirs:
                    _dirs[r] = _hash_dir(r)
            os.makedirs(_D, exist_ok=True)
            with open(os.path.join(_D, '%d.json' % os.getpid()), 'w') as f:
                json.dump({'files': _files, 'dirs': _dirs, 'changed': changed}, f)
        except Exception:
            pass

    sys.addaudithook(_hook)
    atexit.register(_fin)
