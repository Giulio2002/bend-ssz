"""The `_generated` suffix of generated file names: one place, no generator knows about it.

Every generated Bend file carries `_generated` in its file name (`types/FuluBytes1_encode_ssz_generated.bend`). Most generators
name the files they write by a stem of their own (`proofs/obj/arr_copy.bend`), in 180 generator files; this module is the
single place that adds the suffix. A process that imports it (codegen.core.repository_paths does, so every generator does) sees the
repository through a VIEW in which the files listed in `codegen/core/generated_names.txt` still have their stem names:

    on disk                                   what a generator sees and writes
    proofs/obj/arr_copy_generated.bend        proofs/obj/arr_copy.bend
    import ./arr_copy_generated.bend          import ./arr_copy.bend      (in the text of every .bend file it reads or writes)

The view covers `open`, `io.open`, the `os` calls the standard `pathlib` and `glob` are built on (stat, scandir, listdir, unlink,
rename, link), and the import lines of the text it reads and writes. Nothing else changes: contents on disk are the contents the
generator wrote, with the import lines of renamed files spelled with the suffix. `tools/`, `tests_generated/`, `benchmarks/` and the
checker see the real names.

A new generated file is named with the suffix by its generator (add the stem to nothing here): the unit test `test_generated_names`
fails for a generated `.bend` file whose name lacks `_generated` and is not in the list.

    python3 -m codegen.core.generated_names --list      print the list
"""
import builtins
import io
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
_ROOT = str(ROOT)
SUFFIX = '_generated'
_LIST = Path(__file__).with_name('generated_names.txt')


def _load():
    return frozenset(l.strip() for l in _LIST.read_text().split('\n') if l.strip() and not l.startswith('#'))


NAMES = _load() if _LIST.exists() else frozenset()      # virtual repo-relative paths (the stem names)
_DISK = {n[:-5] + SUFFIX + '.bend': n for n in NAMES}  # disk repo-relative path -> virtual path


def to_disk(rel: str) -> str:
    return rel[:-5] + SUFFIX + '.bend' if rel in NAMES else rel


def to_virtual(rel: str) -> str:
    return _DISK.get(rel, rel)


def _rel(path):
    """repo-relative form of an absolute or cwd-relative path under ROOT, or None"""
    try:
        p = os.path.abspath(os.fspath(path))
    except TypeError:
        return None
    if p.startswith(_ROOT + os.sep):
        return p[len(_ROOT) + 1:]
    return None


def _map_path(path, fn):
    """`path` with its repo-relative form mapped by fn (only for names that end in .bend)"""
    if isinstance(path, int):
        return path
    try:
        s = os.fspath(path)
    except TypeError:
        return path
    if isinstance(s, bytes):
        return path
    if not s.endswith('.bend'):
        return path
    r = _rel(s)
    if r is None:
        return path
    m = fn(r)
    return path if m == r else os.path.join(_ROOT, m)


_ON = [True]


class raw:
    """with raw(): the view is off (the real names on disk): copying a tree that tools in the real-name world will read"""

    def __enter__(self):
        _ON.append(_ON[-1] and False)

    def __exit__(self, *x):
        _ON.pop()


def disk_path(path):
    return _map_path(path, to_disk) if _ON[-1] else path


_IMPORT = re.compile(r'^(\s*import\s+)(\S+\.bend)', re.M)
_TOKEN = re.compile(r'(?<![\w/.\-])((?:[\w.\-]+/)+[\w.\-]+\.bend)(?![\w])')      # a repo-relative path of a .bend file in any text
TEXT_EXT = ('.bend', '.md', '.json', '.txt', '.tsv')


def _translate(text: str, rel: 'str | None', fwd: bool) -> str:
    """the import lines of `text` (the module at repo-relative path `rel`) with the targets mapped: virtual -> disk (fwd) or back"""
    if rel is None:
        return text
    d = os.path.dirname(rel)
    fn = to_disk if fwd else to_virtual

    def sub(m):
        t = m.group(2)
        if not t.startswith('.'):
            return m.group(0)
        full = os.path.normpath(os.path.join(d, t))
        new = fn(full)
        if new == full:
            return m.group(0)
        return m.group(1) + t[:-5 - (len(SUFFIX) if not fwd else 0)] + (SUFFIX if fwd else '') + '.bend'
    if 'import' in text and rel.endswith('.bend'):
        text = _IMPORT.sub(sub, text)
    return _TOKEN.sub(lambda m: fn(m.group(1)), text)


class _WriteBuffer(io.StringIO):
    def __init__(self, real_path, vrel, kw):
        super().__init__()
        self._real, self._vrel, self._kw = real_path, vrel, kw

    def close(self):
        if not self.closed:
            data = _translate(self.getvalue(), self._vrel, True)
            with _real_open(self._real, 'w', **self._kw) as f:
                f.write(data)
        super().close()


_real_open = io.open
_real_stat, _real_lstat = os.stat, os.lstat
_real_scandir, _real_listdir = os.scandir, os.listdir
_real_unlink, _real_remove, _real_rename, _real_replace, _real_link = os.unlink, os.remove, os.rename, os.replace, os.link


def _open(file, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True, opener=None):
    if not _ON[-1] or isinstance(file, int):
        return _real_open(file, mode, buffering, encoding, errors, newline, closefd, opener)
    if isinstance(file, (str, os.PathLike)) and os.fspath(file).endswith(TEXT_EXT) and 'b' not in mode and '+' not in mode and opener is None:
        r = _rel(file)
        if r is not None:
            real = disk_path(file)
            if mode.startswith('r'):
                with _real_open(real, mode, buffering, encoding, errors, newline) as f:
                    return io.StringIO(_translate(f.read(), r, False), newline=newline if newline else None)
            if mode.startswith('w'):
                return _WriteBuffer(real, r, {'encoding': encoding, 'errors': errors, 'newline': newline})
    return _real_open(disk_path(file) if isinstance(file, (str, os.PathLike)) else file, mode, buffering, encoding, errors, newline, closefd, opener)


def _wrap(real):
    def f(path, *a, **kw):
        return real(disk_path(path), *a, **kw)
    return f


def _wrap2(real):
    def f(src, dst, *a, **kw):
        return real(disk_path(src), disk_path(dst), *a, **kw)
    return f


class _Entry:
    def __init__(self, e, name):
        self._e, self.name = e, name
        self.path = os.path.join(os.path.dirname(e.path), name)

    def __getattr__(self, k):
        return getattr(self._e, k)

    def __fspath__(self):
        return self.path


def _virt_name(dirpath, name):
    if not _ON[-1] or not name.endswith(SUFFIX + '.bend'):
        return name
    r = _rel(os.path.join(os.fspath(dirpath), name))
    if r is None:
        return name
    return os.path.basename(to_virtual(r))


def _scandir(path='.'):
    it = _real_scandir(disk_path(path) if isinstance(path, (str, os.PathLike)) else path)
    d = os.fspath(path) if isinstance(path, (str, os.PathLike)) else '.'

    class _It:
        def __iter__(self):
            for e in it:
                n = _virt_name(d, e.name)
                yield e if n == e.name else _Entry(e, n)

        def __enter__(self):
            return self

        def __exit__(self, *x):
            it.close()

        def close(self):
            it.close()
    return _It()


def _listdir(path='.'):
    names = _real_listdir(path)
    if isinstance(path, (str, os.PathLike)) and any(n.endswith(SUFFIX + '.bend') for n in names if isinstance(n, str)):
        return [_virt_name(path, n) if isinstance(n, str) else n for n in names]
    return names


def install():
    if getattr(builtins, '_generated_names_installed', False) or not NAMES:
        return
    builtins._generated_names_installed = True
    builtins.open = _open
    io.open = _open
    os.stat, os.lstat = _wrap(_real_stat), _wrap(_real_lstat)
    os.unlink, os.remove = _wrap(_real_unlink), _wrap(_real_remove)
    os.rename, os.replace, os.link = _wrap2(_real_rename), _wrap2(_real_replace), _wrap2(_real_link)
    os.scandir, os.listdir = _scandir, _listdir
    for fn in ('utime', 'chmod', 'access', 'readlink', 'truncate', 'chown', 'open'):
        if hasattr(os, fn):
            setattr(os, fn, _wrap(getattr(os, fn)))


if '--list' in sys.argv[1:] and __name__ == '__main__':
    print('\n'.join(sorted(NAMES)))


def install_for_generators():
    """install the view in a process whose main script is a generator (under codegen/, not codegen/tests/); `GENERATED_NAMES_VIEW=1`
    forces it, `=0` forbids it"""
    force = os.environ.get('GENERATED_NAMES_VIEW')
    if force == '0':
        return
    main = getattr(sys.modules.get('__main__'), '__file__', None)
    if force == '1' or (main and Path(main).resolve().is_relative_to(ROOT / 'codegen') and 'tests' not in Path(main).resolve().parts):
        install()
