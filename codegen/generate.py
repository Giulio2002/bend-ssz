#!/usr/bin/env python3
"""Generate the typed SSZ object runtime from codegen/fulu.yaml.

    /opt/homebrew/bin/python3 codegen/generate.py [--check]

Writes types/fulu_obj.bend: one Bend record per container (one field per SSZ
field) and, for every distinct field shape, the decoder from a validated
window, the encoder into a pre-zeroed output, the size and the root, all
composed from src/obj.bend. It also writes the public per-name operations
(decode, encode, hash_tree_root) and field access for all 109 names, and
types/fulu_obj_index.bend, the dispatch the benchmark programs use.

The generator is not trusted: the output is ordinary Bend checked by the
pinned compiler, its runtime behaviour is checked against the official cases
and fastssz outputs, and its laws are generated separately (codegen/laws.py).
`--check` regenerates in memory and fails if the files on disk differ.

The YAML is parsed by the host (Python + PyYAML): stock Bend has no YAML or
general text parser. Everything downstream of parsing - representation
choice, layout and every emitted definition - is a deterministic function of
the resolved schema tree printed by this script.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import schema  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
RECORD_MAX = 96           # byte vectors / bit vectors up to this many bytes are word records
BOX_MIN = 33              # container fields wider than this many words are boxed (src/obj.bend Boxed)
FLAT_MAX = 64             # a Data container is laid out inline (flattened) by the C backend;
                          # larger containers are linear records so that no generated function
                          # exceeds the backend's 255-slot arity limit


def log2ceil(n):
    d = 0
    while (1 << d) < n:
        d += 1
    return d


def chunks_of(nbytes):
    return max(1, (nbytes + 31) // 32)


class Gen:
    def __init__(self):
        self.shapes = {}      # key -> Shape
        self.order = []
        self.records = {}     # record type name -> number of words (byte/bit records)
        self.out = []

    def shape(self, t):
        k = key(t)
        if k in self.shapes:
            return self.shapes[k]
        s = Shape(self, t)
        self.shapes[k] = s
        s.build()
        self.order.append(s)
        return s


class BoxShape:
    """A container field held behind a pointer (O.Boxed)."""

    def __init__(self, inner):
        self.inner = inner
        self.p = inner.p + '_bx'
        self.kind = 'box'
        self.t = inner.t
        self.fixed = inner.fixed
        self.fsize = inner.fsize
        self.data = False
        self.rep = f'O.Boxed<{inner.rep}>'

    def flat(self):
        return 1


def _gen_boxed(self, inner):
    k = 'BOX:' + inner.p
    if k not in self.shapes:
        b = BoxShape(inner)
        self.shapes[k] = b
        self.order.append(b)
    return self.shapes[k]


Gen.boxed = _gen_boxed


def key(t):
    if t.kind == 'container':
        return 'C:' + t.name
    if t.kind in ('vector', 'list'):
        return f'{t.kind}[{key(t.elem)},{t.size}]'
    return f'{t.kind}{t.size}'


def ident(t):
    if t.kind == 'container':
        return t.name
    if t.kind in ('vector', 'list'):
        return f'{t.kind[0]}{t.size}_{ident(t.elem)}'
    return {'bool': 'bool', 'uint': f'u{8 * t.size}', 'bytes': f'b{t.size}', 'bits': f'bv{t.size}',
            'bytelist': f'bl{t.size}', 'bitlist': f'bits{t.size}'}[t.kind]


class Shape:
    """One SSZ shape: its Bend representation and its generated functions."""

    def __init__(self, g, t):
        self.g, self.t = g, t
        self.p = ident(t)
        self.fixed = t.fixed()
        self.fsize = t.fixed_size() if self.fixed else None
        self.code = []

    # ---- classification ----
    def classify(self):
        t = self.t
        k = t.kind
        if k == 'bool':
            return 'bool'
        if k == 'uint':
            return {1: 'u8', 2: 'u16', 4: 'u32', 8: 'u64'}.get(t.size, 'uwide')
        if k in ('bytes', 'bits'):
            n = t.size if k == 'bytes' else (t.size + 7) // 8
            return 'rec' if n <= RECORD_MAX else 'fixwords'
        if k == 'bytelist':
            return 'bytelist'
        if k == 'bitlist':
            return 'bitlist'
        if k in ('vector', 'list'):
            e = t.elem
            if e.kind in ('bool', 'uint'):
                return 'packed'
            if e.kind == 'bytes' and e.size == 32:
                return 'packed'
            if e.kind == 'bytes' and e.size % 4 == 0:
                return 'packed_elems'
            return 'seq'
        return 'container'

    def build(self):
        self.kind = self.classify()
        t = self.t
        if self.kind in ('rec', 'uwide'):
            nbytes = t.size if t.kind != 'bits' else (t.size + 7) // 8
            self.nbytes = nbytes
            self.nw = (nbytes + 3) // 4
            self.rep = {'bytes': f'Bytes{t.size}', 'bits': f'Bitvector{t.size}', 'uint': f'Uint{8 * t.size}'}[t.kind]
            self.g.records[self.rep] = self.nw
        elif self.kind == 'seq':
            self.elem = self.g.shape(t.elem)
        elif self.kind == 'container':
            self.fields = []
            for f, ft in t.fields:
                fs = self.g.shape(ft)
                if fs.kind == 'container' and fs.flat_inline() >= BOX_MIN:
                    fs = self.g.boxed(fs)
                self.fields.append((f, fs))
        self.data = self.is_data()
        if self.kind in ('seq',):
            self.rep = f'Array<{self.elem.rep}>'
        self.rep = self.representation()

    def is_data(self):
        if self.kind in ('bool', 'u8', 'u16', 'u32', 'u64', 'uwide', 'rec'):
            return True
        if self.kind == 'container':
            return all(s.data for _, s in self.fields) and self.flat() <= FLAT_MAX
        return False

    def flat(self):
        """Slots of the value's inline layout (a linear value is one pointer)."""
        k = self.kind
        if k in ('bool', 'u8', 'u16', 'u32'):
            return 1
        if k == 'u64':
            return 2
        if k in ('rec', 'uwide'):
            return self.nw
        if k in ('fixwords', 'bytelist', 'packed', 'packed_elems', 'bitlist', 'seq'):
            return 2
        if k == 'box':
            return 1
        if k == 'container':
            return self.flat_inline()
        return 1

    def flat_inline(self):
        """Words of this container's own inline layout (boxed fields are one word)."""
        if self.kind != 'container':
            return self.flat()
        return sum(fs.flat() for _, fs in self.fields)

    def representation(self):
        k = self.kind
        if k == 'bool':
            return 'Bool'
        if k in ('u8', 'u16', 'u32'):
            return 'U32'
        if k == 'u64':
            return 'O.U64'
        if k in ('rec', 'uwide'):
            return self.rep
        if k in ('fixwords', 'bytelist', 'packed', 'packed_elems'):
            return 'O.Words'
        if k == 'bitlist':
            return 'O.Bits'
        if k == 'seq':
            return f'{self.p}_Seq'
        return self.t.name


def emit_all(g, names):
    for n, t in names.items():
        g.shape(t)
    lines = []
    w = lines.append
    w('import Base')
    w('import ../src/buffer.bend as B')
    w('import ../src/digest.bend as D')
    w('import ../src/merkle_fast.bend as M')
    w('import ../src/obj.bend as O')
    w('')
    w('# GENERATED by codegen/generate.py from codegen/fulu.yaml. Do not edit.')
    w('# Typed owning SSZ objects for the 109 mainnet Fulu names: records,')
    w('# decode (validate with src/cscan.bend, then build), encode, size, root.')
    w('')
    for rec, nw in sorted(g.records.items()):
        w(f'type {rec} is Data:')
        w(f'  {rec}{{' + ', '.join(f'w{i}: U32' for i in range(nw)) + '}')
        w('')
    for s in g.order:
        emit_shape(s, w)
    ops = {}
    for n, t in names.items():
        emit_api(g, n, g.shape(t), w)
        ops[n] = emit_fuzz(g, n, g.shape(t), w)
    g.fuzz_ops = ops
    return '\n'.join(lines) + '\n'


# ---------------------------------------------------------------------------
# Emission helpers.

def plus(s):
    return '+' if s.data else ''


def emit_shape(s, w):
    fn = {
        'bool': emit_bool, 'u8': emit_uint, 'u16': emit_uint, 'u32': emit_uint, 'u64': emit_u64,
        'uwide': emit_rec, 'rec': emit_rec, 'fixwords': emit_words, 'bytelist': emit_words,
        'packed': emit_words, 'packed_elems': emit_words, 'bitlist': emit_bitlist,
        'seq': emit_seq, 'container': emit_container, 'box': emit_box,
    }[s.kind]
    fn(s, w)
    if s.kind != 'box':
        emit_force(s, w)
    emit_ok(s, w)
    if s.kind in ('rec', 'uwide'):
        emit_word_codec(s.rep, s.nw, w)
    emit_access(s, w)
    if seedable(s):
        emit_seed(s, w)
    if s.kind == 'seq' and s.t.kind == 'list':
        emit_seq_cache(s, w)
    w('')


def emit_box(s, w):
    """A boxed container field: unwrap, apply the inner function, rewrap."""
    i, p, R = s.inner, s.p, s.inner.rep
    B_ = s.rep
    w(f'def {p}_wrap(v: {R}) -> {B_}: O.BSome{{v, O.BNone{{}}}}')
    w(f'def {p}_default() -> {B_}: {p}_wrap({i.p}_default())')
    w(f'def {p}_rd(pair: B.Buf & {R}) -> B.Buf & {B_}:')
    w(f'  (buf, {plus(i)}v) = pair')
    w(f'  (buf, {p}_wrap(v))')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & {B_}: {p}_rd({i.p}_read(buf, off, len))')
    # unwrap: the second arm is never built
    def unwrap(fn, none):
        return f'  match o:\n    case O.BSome{{{"+" if i.data else ""}v, rest}}: {fn}\n    case O.BNone{{}}: {none}'
    if i.data:
        w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {B_}) -> Array<U32> & {B_}:')
        w(unwrap(f'({i.p}_put(out, pos, v), {p}_wrap(v))', f'(out, {p}_default())'))
        w(f'def {p}_size(o: {B_}) -> {B_} & U32: (o, {i.fsize})')
        w(f'def {p}_rt(+v: {R}, pair: B.Buf & D.Digest) -> B.Buf & ({B_} & D.Digest):')
        w('  (h, d) = pair')
        w(f'  (h, ({p}_wrap(v), d))')
        w(f'def {p}_root(h: B.Buf, o: {B_}, +seg: U32) -> B.Buf & ({B_} & D.Digest):')
        w(unwrap(f'{p}_rt(v, {i.p}_root(h, v, seg))', f'(h, ({p}_default(), D.zero()))'))
        w(f'def {p}_force(o: {B_}) -> {B_} & U32:')
        w(unwrap(f'({p}_wrap(v), {i.p}_force(v))', f'({p}_default(), 0)'))
        return
    w(f'def {p}_put_back(pair: Array<U32> & {R}) -> Array<U32> & {B_}:')
    w('  (out, v) = pair')
    w(f'  (out, {p}_wrap(v))')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {B_}) -> Array<U32> & {B_}:')
    w(unwrap(f'{p}_put_back({i.p}_put(out, pos, v))', f'(out, {p}_default())'))
    w(f'def {p}_size_back(pair: {R} & U32) -> {B_} & U32:')
    w('  (v, +n) = pair')
    w(f'  ({p}_wrap(v), n)')
    w(f'def {p}_size(o: {B_}) -> {B_} & U32:')
    w(unwrap(f'{p}_size_back({i.p}_size(v))', f'({p}_default(), 0)'))
    w(f'def {p}_rt(pair: B.Buf & ({R} & D.Digest)) -> B.Buf & ({B_} & D.Digest):')
    w('  (h, r) = pair')
    w('  (v, d) = r')
    w(f'  (h, ({p}_wrap(v), d))')
    w(f'def {p}_root(h: B.Buf, o: {B_}, +seg: U32) -> B.Buf & ({B_} & D.Digest):')
    w(unwrap(f'{p}_rt({i.p}_root(h, v, seg))', f'(h, ({p}_default(), D.zero()))'))
    w(f'def {p}_force(o: {B_}) -> {B_} & U32:')
    w(unwrap(f'{p}_size_back({i.p}_force(v))', f'({p}_default(), 0)'))


# ---------------------------------------------------------------------------
# Validation. `{p}_ok(buf, off, len)` decides whether the window is a valid
# encoding; fixed shapes also get `{p}_ok_at(buf, off)` for their content
# checks alone (booleans, bit-vector padding), and `chk(s)` says whether they
# have any. Decoding runs the validator and then the (unchecked) reader.

def u32_limit(n):
    """A limit as (U32 literal, big flag): big means no U32 length exceeds it."""
    return (n, 'False{}') if n < (1 << 32) else (0, 'True{}')


def chk(s):
    k = s.kind
    if k == 'bool':
        return True
    if k in ('rec', 'fixwords') and s.t.kind == 'bits':
        return s.t.size % 8 != 0
    if k in ('packed',) and s.t.elem.kind == 'bool':
        return True
    if k == 'seq' and s.elem.fixed:
        return chk(s.elem)
    if k == 'container':
        return any(chk(fs) for _, fs in s.fields)
    if k == 'box':
        return chk(s.inner)
    return False


def within(expr, n):
    lim, big = u32_limit(n)
    return 'True{}' if big == 'True{}' else f'U32.is_le({expr}, {lim})'


def emit_ok(s, w):
    p, k, t = s.p, s.kind, s.t
    if k == 'box':
        i = s.inner
        w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {i.p}_ok(buf, off, len)')
        if i.fixed:
            w(f'def {p}_ok_at(buf: B.Buf, +off: U32) -> B.Buf & Bool: {i.p}_ok_at(buf, off)')
        return
    if s.fixed:
        # content checks at a known position
        if k == 'bool':
            w(f'def {p}_ok_at(buf: B.Buf, +off: U32) -> B.Buf & Bool: O.ok_bool(buf, off)')
        elif k in ('rec', 'fixwords') and t.kind == 'bits' and t.size % 8:
            w(f'def {p}_ok_at(buf: B.Buf, +off: U32) -> B.Buf & Bool: O.ok_pad(buf, (off + {(t.size + 7) // 8 - 1} : U32), {t.size % 8})')
        elif k == 'packed' and t.elem.kind == 'bool':
            emit_elem_loop(s, w, t.size, 1, 'O.ok_bool')
        elif k == 'seq' and chk(s.elem):
            emit_elem_loop(s, w, t.size, s.elem.fsize, f'{s.elem.p}_ok_at')
        elif k == 'container':
            emit_container_ok(s, w, fixed=True)
            return
        else:
            w(f'def {p}_ok_at(buf: B.Buf, +off: U32) -> B.Buf & Bool: (buf, True{{}})')
        w(f'def {p}_ok_len(ok: Bool, buf: B.Buf, +off: U32) -> B.Buf & Bool:')
        w('  match ok:')
        w(f'    case True{{}}: {p}_ok_at(buf, off)')
        w('    case False{}: (buf, False{})')
        w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {p}_ok_len(U32.is_eq(len, {s.fsize}), buf, off)')
        return
    if k == 'bytelist':
        w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: (buf, {within("len", t.size)})')
    elif k == 'bitlist':
        lim, big = u32_limit(t.size)
        w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: O.ok_bitlist(buf, off, len, {lim}, {big})')
    elif k in ('packed', 'packed_elems') or (k == 'seq' and s.elem.fixed):
        es = t.elem.fixed_size()
        shape_ok = f'Bool.and(U32.is_eq(len, (U32.div(len, {es}) * {es} : U32)), {within(f"U32.div(len, {es})", t.size)})'
        echk = (k == 'packed' and t.elem.kind == 'bool') or (k == 'seq' and chk(s.elem))
        if echk:
            fn = 'O.ok_bool' if k == 'packed' else f'{s.elem.p}_ok_at'
            emit_elem_loop(s, w, None, es, fn)
            w(f'def {p}_ok_len(ok: Bool, buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool:')
            w('  match ok:')
            w(f'    case True{{}}: {p}_ok_n(buf, off, U32.div(len, {es}))')
            w('    case False{}: (buf, False{})')
            w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {p}_ok_len({shape_ok}, buf, off, len)')
        else:
            w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: (buf, {shape_ok})')
    elif k == 'seq':
        emit_var_elems_ok(s, w)
    elif k == 'container':
        emit_container_ok(s, w, fixed=False)


def emit_elem_loop(s, w, count, es, fn):
    """Check every element of a fixed-element sequence (count known or n)."""
    p = s.p
    w(f'def {p}_ck(+k: Nat, +i: U32, +off: U32, +acc: Bool, pair: B.Buf & Bool) -> B.Buf & Bool:')
    w('  match k:')
    w('    case 0n: O.and_pair(acc, pair)')
    w('    case 1n+q:')
    w('      (buf, ok) = pair')
    w(f'      {p}_ck(q, (i + 1 : U32), off, Bool.and(acc, ok), {fn}(buf, (off + (i + 1 : U32) * {es} : U32)))')
    w(f'def {p}_ok_n(buf: B.Buf, +off: U32, +n: U32) -> B.Buf & Bool:')
    w(f'  {p}_ok_nz(U32.is_eq(n, 0), buf, off, n)')
    w(f'def {p}_ok_nz(empty: Bool, buf: B.Buf, +off: U32, +n: U32) -> B.Buf & Bool:')
    w('  match empty:')
    w('    case True{}: (buf, True{})')
    w(f'    case False{{}}: {p}_ck(U32.to_nat((n - 1 : U32)), 0, off, True{{}}, {fn}(buf, off))')
    if count is not None:
        w(f'def {p}_ok_at(buf: B.Buf, +off: U32) -> B.Buf & Bool: {p}_ok_n(buf, off, {count})')


def emit_var_elems_ok(s, w):
    """A sequence of variable-size elements: the offsets table, then each element."""
    p, t, E = s.p, s.t, s.elem.p
    # element i: [s, e) with s the previous end; e = next offset or len
    w(f'def {p}_ew(ok: Bool, buf: B.Buf, +off: U32, +a: U32, +b: U32) -> B.Buf & Bool:')
    w('  match ok:')
    w(f'    case True{{}}: {E}_ok(buf, (off + a : U32), (b - a : U32))')
    w('    case False{}: (buf, False{})')
    w(f'def {p}_ee(+acc: Bool, +off: U32, +len: U32, +a: U32, pair: B.Buf & U32) -> B.Buf & (Bool & U32):')
    w('  (buf, +b) = pair')
    w(f'  {p}_eb(b, O.and_pair(acc, {p}_ew(Bool.and(acc, Bool.and(U32.is_le(a, b), U32.is_le(b, len))), buf, off, a, b)))')
    w(f'def {p}_eb(+b: U32, pair: B.Buf & Bool) -> B.Buf & (Bool & U32):')
    w('  (buf, ok) = pair')
    w('  (buf, (ok, b))')
    w(f'def {p}_next(last: Bool, buf: B.Buf, +off: U32, +len: U32, +i: U32) -> B.Buf & U32:')
    w('  match last:')
    w('    case True{}: (buf, len)')
    w('    case False{}: B.read32(buf, (off + 4 * (i + 1 : U32) : U32))')
    w(f'def {p}_ev(+k: Nat, +i: U32, +n: U32, +off: U32, +len: U32, pair: B.Buf & (Bool & U32)) -> B.Buf & Bool:')
    w('  match k:')
    w('    case 0n:')
    w('      (buf, r) = pair')
    w('      (ok, a) = r')
    w('      (buf, ok)')
    w('    case 1n+q:')
    w('      (buf, r) = pair')
    w('      (ok, a) = r')
    w(f'      {p}_ev(q, (i + 1 : U32), n, off, len, {p}_ee(ok, off, len, a, {p}_next(U32.is_eq((i + 2 : U32), n), buf, off, len, (i + 1 : U32))))')
    w(f'def {p}_first(ok: Bool, buf: B.Buf, +off: U32, +len: U32, +first: U32) -> B.Buf & Bool:')
    w('  match ok:')
    w(f'    case True{{}}: {p}_ev(U32.to_nat((U32.shrn(first, 2n) - 1 : U32)), 0, U32.shrn(first, 2n), off, len, {p}_ee(True{{}}, off, len, first, {p}_next(U32.is_eq(1, U32.shrn(first, 2n)), buf, off, len, 0)))')
    w('    case False{}: (buf, False{})')
    count_ok = (f'U32.is_eq(first, {4 * t.size})' if t.kind == 'vector'
                else f'Bool.and(U32.is_le(4, first), {within("U32.shrn(first, 2n)", t.size)})')
    w(f'def {p}_head(+len: U32, +off: U32, pair: B.Buf & U32) -> B.Buf & Bool:')
    w('  (buf, +first) = pair')
    w(f'  {p}_first(Bool.and(Bool.and(U32.is_eq((first .&. 3 : U32), 0), U32.is_le(first, len)), {count_ok}), buf, off, len, first)')
    w(f'def {p}_ok_nz(empty: Bool, buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool:')
    w('  match empty:')
    w('    case True{}: (buf, ' + ('True{}' if t.kind == 'list' else 'False{}') + ')')
    w(f'    case False{{}}: {p}_head(len, off, B.read32(buf, off))')
    w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {p}_ok_nz(U32.is_eq(len, 0), buf, off, len)')


def emit_container_ok(s, w, fixed):
    p, F = s.p, s.fields
    hoff, fp = container_layout(F)
    names = [f for f, _ in F]
    var = [i for i, (f, fs) in enumerate(F) if not fs.fixed]
    steps = [('off', i) for i in var]
    steps += [('fixed', i) for i, (f, fs) in enumerate(F) if fs.fixed and chk(fs)]
    steps += [('var', i) for i in var]
    ofs = [f'o{j}' for j in range(len(var))]

    def call(st):
        kind_, i = st
        if kind_ == 'off':
            return f'B.read32(buf, (off + {hoff[i]} : U32))'
        if kind_ == 'fixed':
            return f'{F[i][1].p}_ok_at(buf, (off + {hoff[i]} : U32))'
        j = var.index(i)
        end = ofs[j + 1] if j + 1 < len(var) else 'len'
        return f'{F[i][1].p}_ok(buf, (off + {ofs[j]} : U32), ({end} - {ofs[j]} : U32))'

    def known(k):
        return ofs[:sum(1 for x in steps[:k] if x[0] == 'off')]

    entry = 'ok_at' if fixed else 'ok_go'
    sig_len = '' if fixed else ', +len: U32'
    arg_len = '' if fixed else ', len'
    for k in range(len(steps) - 1, -1, -1):
        st = steps[k]
        kn = known(k)
        kp = ''.join(f', +{o}: U32' for o in kn)
        ka = ''.join(f', {o}' for o in kn)
        if st[0] == 'off':
            j = var.index(st[1])
            me = ofs[j]
            cond = f'U32.is_eq({me}, {fp})' if j == 0 else f'Bool.and(U32.is_le({ofs[j - 1]}, {me}), U32.is_le({me}, len))'
            if j == 0 and len(var) == 1:
                cond = f'U32.is_eq({me}, {fp})'
            w(f'def {p}_v{k}(+off: U32{sig_len}{kp}, pair: B.Buf & U32) -> B.Buf & Bool:')
            w(f'  (buf, +{me}) = pair')
            w(f'  {p}_c{k}({cond}, buf, off{arg_len}{ka}, {me})')
            kp2, ka2 = kp + f', +{me}: U32', ka + f', {me}'
        else:
            w(f'def {p}_v{k}(+off: U32{sig_len}{kp}, pair: B.Buf & Bool) -> B.Buf & Bool:')
            w('  (buf, ok) = pair')
            w(f'  {p}_c{k}(ok, buf, off{arg_len}{ka})')
            kp2, ka2 = kp, ka
        w(f'def {p}_c{k}(ok: Bool, buf: B.Buf, +off: U32{sig_len}{kp2}) -> B.Buf & Bool:')
        w('  match ok:')
        if k == len(steps) - 1:
            w('    case True{}: (buf, True{})')
        else:
            w(f'    case True{{}}: {p}_v{k + 1}(off{arg_len}{ka2}, {call(steps[k + 1])})')
        w('    case False{}: (buf, False{})')
    if fixed:
        if steps:
            w(f'def {p}_ok_at(buf: B.Buf, +off: U32) -> B.Buf & Bool: {p}_v0(off, {call(steps[0])})')
        else:
            w(f'def {p}_ok_at(buf: B.Buf, +off: U32) -> B.Buf & Bool: (buf, True{{}})')
        w(f'def {p}_ok_len(ok: Bool, buf: B.Buf, +off: U32) -> B.Buf & Bool:')
        w('  match ok:')
        w(f'    case True{{}}: {p}_ok_at(buf, off)')
        w('    case False{}: (buf, False{})')
        w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {p}_ok_len(U32.is_eq(len, {fp}), buf, off)')
    else:
        # the last variable field must also end within the window (checked
        # by the last offset's condition); the first offset equals the fixed
        # part, which the length check has already bounded
        w(f'def {p}_ok_len(ok: Bool, buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool:')
        w('  match ok:')
        w(f'    case True{{}}: {p}_v0(off, len, {call(steps[0])})')
        w('    case False{}: (buf, False{})')
        w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {p}_ok_len(U32.is_le({fp}, len), buf, off, len)')


# ---------------------------------------------------------------------------
# Access and mutation. Every field of a container can be read and replaced, and
# every collection supports indexed read/replace; lists also support a bounded
# append. Out-of-range indices, out-of-domain scalars and appends past the
# declared limit are rejected and leave the value unchanged (the API consumes
# and returns the owning object, as Bend's affine rules require).

def scalar_ok(s, val):
    """Domain check of a scalar being written into a field or element."""
    k = s.kind
    if k == 'u8':
        return f'U32.is_le({val}, 255)'
    if k == 'u16':
        return f'U32.is_le({val}, 65535)'
    return None


def emit_word_codec(rec, nw, w):
    """Read/replace a word record inside packed storage (aligned position)."""
    ws = [f'w{i}' for i in range(nw)]
    for i in range(nw - 1, -1, -1):
        prev = ''.join(f'+{x}: U32, ' for x in ws[:i])
        w(f'def {rec}_wr{i}(+j: U32, {prev}pair: O.Words & U32) -> O.Words & {rec}:')
        w('  (o, +x) = pair')
        if i == nw - 1:
            w(f'  (o, {rec}{{' + ', '.join(ws[:i] + ['x']) + '})')
        else:
            w(f'  {rec}_wr{i + 1}(j, ' + ', '.join(ws[:i] + ['x']) + f', O.words_word(o, (j + {i + 1} : U32)))')
    w(f'def {rec}_of_words(o: O.Words, +p: U32) -> O.Words & {rec}: {rec}_wr0(U32.shrn(p, 2n), O.words_word(o, U32.shrn(p, 2n)))')
    expr = 'o'
    for i, x in enumerate(ws):
        expr = f'O.words_setw({expr}, (U32.shrn(p, 2n) + {i} : U32), {x})'
    w(f'def {rec}_into_words(o: O.Words, +p: U32, v: {rec}) -> O.Words:')
    w('  match v:')
    w(f'    case {rec}{{' + ', '.join('+' + x for x in ws) + f'}}: {expr}')


def emit_access(s, w):
    k, p, t = s.kind, s.p, s.t
    if k in ('packed', 'packed_elems', 'bytelist'):
        byteish = k == 'bytelist'
        el = None if byteish else s.g.shape(t.elem)
        es = 1 if byteish else t.elem.fixed_size()
        er = 'U32' if byteish else el.rep
        pl = '+' if byteish else plus(el)
        ekind = 'uint' if byteish else t.elem.kind
        is_list = t.kind in ('list', 'bytelist')
        w(f'def {p}_len_of(pair: O.Words & U32) -> O.Words & U32:')
        w('  (o, +n) = pair')
        w(f'  (o, U32.div(n, {es}))')
        w(f'def {p}_len(o: O.Words) -> O.Words & U32: {p}_len_of(O.words_len(o))')
        if ekind == 'bool':
            w(f'def {p}_bool_at(pair: O.Words & U32) -> O.Words & Bool:')
            w('  (o, +x) = pair')
            w('  (o, U32.is_eq(x, 1))')
            rd = f'{p}_bool_at(O.words_byte_at(o, i, 1))'
            wr = f'O.words_write(o, i, O.pick(v, 1, 0), 1)'
            dom = None
        elif ekind == 'uint' and es == 8:
            rd = 'O.words_u64_at(o, (i * 8 : U32))'
            wr = 'O.words_write_u64(o, (i * 8 : U32), v)'
            dom = None
        elif ekind == 'uint' and es <= 4:
            rd = f'O.words_byte_at(o, (i * {es} : U32), {es})'
            wr = f'O.words_write(o, (i * {es} : U32), v, {es})'
            dom = scalar_ok(el, 'v') if el is not None else 'U32.is_le(v, 255)'
        elif ekind == 'uint':
            rd = f'{er}_of_words(o, (i * {es} : U32))'
            wr = f'{er}_into_words(o, (i * {es} : U32), v)'
            dom = None
        elif er == 'O.Words':
            rd = f'O.words_slice(o, (i * {es} : U32), {es})'
            wr = f'{p}_blit(O.words_blit(o, (i * {es} : U32), v))'
            dom = None
            w(f'def {p}_blit(pair: O.Words & O.Words) -> O.Words:')
            w('  (o, src) = pair')
            w('  o')
        else:
            rd = f'{er}_of_words(o, (i * {es} : U32))'
            wr = f'{er}_into_words(o, (i * {es} : U32), v)'
            dom = None
        w(f'def {p}_at(o: O.Words, +i: U32) -> O.Words & {er}: {rd}')
        w(f'def {p}_some(pair: O.Words & {er}) -> O.Words & Maybe<&1, {er}>:')
        w(f'  (o, {pl}v) = pair')
        w('  (o, Some{v})')
        w(f'def {p}_get_in(inside: Bool, o: O.Words, +i: U32) -> O.Words & Maybe<&1, {er}>:')
        w('  match inside:')
        w(f'    case True{{}}: {p}_some({p}_at(o, i))')
        w('    case False{}: (o, None{})')
        w(f'def {p}_get_n(+i: U32, pair: O.Words & U32) -> O.Words & Maybe<&1, {er}>:')
        w('  (o, +n) = pair')
        w(f'  {p}_get_in(U32.is_lt(i, n), o, i)')
        w(f'def {p}_get(o: O.Words, +i: U32) -> O.Words & Maybe<&1, {er}>: {p}_get_n(i, {p}_len(o))')
        w(f'def {p}_put_at(ok: Bool, o: O.Words, +i: U32, {pl}v: {er}) -> O.Words & Bool:')
        w('  match ok:')
        w(f'    case True{{}}: ({wr}, True{{}})')
        w('    case False{}: (o, False{})')
        cond = 'U32.is_lt(i, n)' if dom is None else f'Bool.and(U32.is_lt(i, n), {dom})'
        w(f'def {p}_set_n(+i: U32, {pl}v: {er}, pair: O.Words & U32) -> O.Words & Bool:')
        w('  (o, +n) = pair')
        w(f'  {p}_put_at({cond}, o, i, v)')
        w(f'def {p}_set(o: O.Words, +i: U32, {pl}v: {er}) -> O.Words & Bool: {p}_set_n(i, v, {p}_len(o))')
        if is_list:
            w(f'def {p}_grow(ok: Bool, o: O.Words, +n: U32, {pl}v: {er}) -> O.Words & Bool:')
            w('  match ok:')
            w(f'    case True{{}}: {p}_put_at(True{{}}, O.words_resize(O.words_fit(o, ((n + 1 : U32) * {es} : U32)), ((n + 1 : U32) * {es} : U32)), n, v)')
            w('    case False{}: (o, False{})')
            lim_ok = within('(n + 1 : U32)', t.size)
            acond = lim_ok if dom is None else f'Bool.and({lim_ok}, {dom})'
            w(f'def {p}_app_n({pl}v: {er}, pair: O.Words & U32) -> O.Words & Bool:')
            w('  (o, +n) = pair')
            w(f'  {p}_grow({acond}, o, n, v)')
            w(f'def {p}_append(o: O.Words, {pl}v: {er}) -> O.Words & Bool: {p}_app_n(v, {p}_len(o))')
        return
    if k in ('fixwords',):
        # a large fixed byte or bit vector: indexed bytes, fixed length
        w(f'def {p}_len(o: O.Words) -> O.Words & U32: O.words_len(o)')
        w(f'def {p}_get(o: O.Words, +i: U32) -> O.Words & Maybe<&1, U32>: {p}_get_n(i, O.words_len(o))')
        w(f'def {p}_get_n(+i: U32, pair: O.Words & U32) -> O.Words & Maybe<&1, U32>:')
        w('  (o, +n) = pair')
        w(f'  {p}_get_in(U32.is_lt(i, n), o, i)')
        w(f'def {p}_get_in(inside: Bool, o: O.Words, +i: U32) -> O.Words & Maybe<&1, U32>:')
        w('  match inside:')
        w(f'    case True{{}}: {p}_some(O.words_byte_at(o, i, 1))')
        w('    case False{}: (o, None{})')
        w(f'def {p}_some(pair: O.Words & U32) -> O.Words & Maybe<&1, U32>:')
        w('  (o, +v) = pair')
        w('  (o, Some{v})')
        w(f'def {p}_put_at(ok: Bool, o: O.Words, +i: U32, +v: U32) -> O.Words & Bool:')
        w('  match ok:')
        w('    case True{}: (O.words_write(o, i, v, 1), True{})')
        w('    case False{}: (o, False{})')
        w(f'def {p}_set_n(+i: U32, +v: U32, pair: O.Words & U32) -> O.Words & Bool:')
        w('  (o, +n) = pair')
        w(f'  {p}_put_at(Bool.and(U32.is_lt(i, n), U32.is_le(v, 255)), o, i, v)')
        w(f'def {p}_set(o: O.Words, +i: U32, +v: U32) -> O.Words & Bool: {p}_set_n(i, v, O.words_len(o))')
        return
    if k == 'bitlist':
        w(f'def {p}_len(o: O.Bits) -> O.Bits & U32: O.bits_len(o)')
        w(f'def {p}_get(o: O.Bits, +i: U32) -> O.Bits & Maybe<&1, Bool>: {p}_get_n(i, O.bits_len(o))')
        w(f'def {p}_get_n(+i: U32, pair: O.Bits & U32) -> O.Bits & Maybe<&1, Bool>:')
        w('  (o, +n) = pair')
        w(f'  {p}_get_in(U32.is_lt(i, n), o, i)')
        w(f'def {p}_get_in(inside: Bool, o: O.Bits, +i: U32) -> O.Bits & Maybe<&1, Bool>:')
        w('  match inside:')
        w(f'    case True{{}}: {p}_some(O.bits_get(o, i))')
        w('    case False{}: (o, None{})')
        w(f'def {p}_some(pair: O.Bits & Bool) -> O.Bits & Maybe<&1, Bool>:')
        w('  (o, v) = pair')
        w('  (o, Some{v})')
        w(f'def {p}_put_at(ok: Bool, o: O.Bits, +i: U32, v: Bool) -> O.Bits & Bool:')
        w('  match ok:')
        w('    case True{}: (O.bits_set(o, i, v), True{})')
        w('    case False{}: (o, False{})')
        w(f'def {p}_set_n(+i: U32, v: Bool, pair: O.Bits & U32) -> O.Bits & Bool:')
        w('  (o, +n) = pair')
        w(f'  {p}_put_at(U32.is_lt(i, n), o, i, v)')
        w(f'def {p}_set(o: O.Bits, +i: U32, v: Bool) -> O.Bits & Bool: {p}_set_n(i, v, O.bits_len(o))')
        w(f'def {p}_push(ok: Bool, o: O.Bits, v: Bool) -> O.Bits & Bool:')
        w('  match ok:')
        w('    case True{}: (O.bits_push(o, v), True{})')
        w('    case False{}: (o, False{})')
        w(f'def {p}_app_n(v: Bool, pair: O.Bits & U32) -> O.Bits & Bool:')
        w('  (o, +n) = pair')
        w(f'  {p}_push({within("(n + 1 : U32)", t.size)}, o, v)')
        w(f'def {p}_append(o: O.Bits, v: Bool) -> O.Bits & Bool: {p}_app_n(v, O.bits_len(o))')
        return
    if k == 'seq':
        e, S, Re, E = s.elem, f'{p}_Seq', s.elem.rep, s.elem.p
        w(f'def {p}_len(o: {S}) -> {S} & U32:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: ({S}{{arr, n}}, n)')
        # read: Data elements are copied out, linear ones swapped out and back
        if e.data:
            w(f'def {p}_at(arr: Array<{Re}>, +n: U32, +i: U32) -> {S} & Maybe<&1, {Re}>:')
            w(f'  {p}_took(n, Array.get({Re}, arr, i))')
            w(f'def {p}_took(+n: U32, pair: Array<{Re}> & {Re}) -> {S} & Maybe<&1, {Re}>:')
            w('  (arr, +v) = pair')
            w(f'  ({S}{{arr, n}}, Some{{v}})')
        else:
            w(f'def {p}_at(arr: Array<{Re}>, +n: U32, +i: U32) -> {S} & Maybe<&1, {Re}>:')
            w(f'  {p}_took(n, Array.swap({Re}, arr, i, {E}_default()))')
            w(f'def {p}_took(+n: U32, pair: Array<{Re}> & {Re}) -> {S} & Maybe<&1, {Re}>:')
            w('  (arr, v) = pair')
            w(f'  ({S}{{arr, n}}, Some{{v}})')
        w(f'def {p}_get_in(inside: Bool, arr: Array<{Re}>, +n: U32, +i: U32) -> {S} & Maybe<&1, {Re}>:')
        w('  match inside:')
        w(f'    case True{{}}: {p}_at(arr, n, i)')
        w(f'    case False{{}}: ({S}{{arr, n}}, None{{}})')
        w(f'def {p}_get(o: {S}, +i: U32) -> {S} & Maybe<&1, {Re}>:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_get_in(U32.is_lt(i, n), arr, n, i)')
        w(f'def {p}_put_in(ok: Bool, arr: Array<{Re}>, +n: U32, +i: U32, v: {Re}) -> {S} & Bool:')
        w('  match ok:')
        w(f'    case True{{}}: ({S}{{Array.set({Re}, arr, i, v), n}}, True{{}})')
        w(f'    case False{{}}: ({S}{{arr, n}}, False{{}})')
        w(f'def {p}_set(o: {S}, +i: U32, v: {Re}) -> {S} & Bool:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_put_in(U32.is_lt(i, n), arr, n, i, v)')
        if t.kind == 'list':
            # append: when the packed array of elements is full it doubles,
            # so the storage cost of an append is amortised O(1) and the
            # worst-case reallocation copies the n elements once.
            w(f'def {p}_moved(+i: U32, fresh: Array<{Re}>, pair: Array<{Re}> & {Re}) -> Array<{Re}> & Array<{Re}>:')
            w('  (old, v) = pair')
            w(f'  (Array.set({Re}, fresh, i, v), old)')
            w(f'def {p}_copy(+k: Nat, +i: U32, pair: Array<{Re}> & Array<{Re}>) -> Array<{Re}>:')
            w('  match k:')
            w('    case 0n:')
            w('      (fresh, old) = pair')
            w('      fresh')
            w('    case 1n+q:')
            w('      (fresh, old) = pair')
            w(f'      {p}_copy(q, (i + 1 : U32), {p}_moved(i, fresh, Array.swap({Re}, old, i, {E}_default())))')
            w(f'def {p}_room_pick(fits: Bool, arr: Array<{Re}>, +n: U32) -> Array<{Re}>:')
            w('  match fits:')
            w('    case True{}: arr')
            w(f'    case False{{}}: {p}_copy(U32.to_nat(n), 0, ({p}_fill({p}_cap((n + 1 : U32))), arr))')
            w(f'def {p}_room_sized(+n: U32, pair: Array<{Re}> & U32) -> Array<{Re}>:')
            w('  (arr, +cap) = pair')
            w(f'  {p}_room_pick(U32.is_lt(n, cap), arr, n)')
            w(f'def {p}_room(arr: Array<{Re}>, +n: U32) -> Array<{Re}>: {p}_room_sized(n, Array.size({Re}, arr))')
            w(f'def {p}_app_in(ok: Bool, arr: Array<{Re}>, +n: U32, v: {Re}) -> {S} & Bool:')
            w('  match ok:')
            w(f'    case True{{}}: ({S}{{Array.set({Re}, {p}_room(arr, n), n, v), (n + 1 : U32)}}, True{{}})')
            w(f'    case False{{}}: ({S}{{arr, n}}, False{{}})')
            w(f'def {p}_append(o: {S}, v: {Re}) -> {S} & Bool:')
            w('  match o:')
            w(f'    case {S}{{arr, +n}}: {p}_app_in({within("(n + 1 : U32)", t.size)}, arr, n, v)')
        return


def emit_force(s, w):
    """A fold over every scalar of the value. The runtime evaluates record
    fields lazily; decode benchmarks consume the whole object through this,
    so no construction work is left unevaluated. Packed arrays are strict."""
    p, k, R = s.p, s.kind, s.rep
    if k == 'bool':
        w(f'def {p}_force(o: Bool) -> U32: O.pick(o, 1, 0)')
    elif k in ('u8', 'u16', 'u32'):
        w(f'def {p}_force(+o: U32) -> U32: o')
    elif k == 'u64':
        w(f'def {p}_force(o: O.U64) -> U32:')
        w('  match o:')
        w('    case O.U64{+lo, +hi}: (lo .^. hi : U32)')
    elif k in ('rec', 'uwide'):
        ws = [f'w{i}' for i in range(s.nw)]
        x = ws[0]
        for y in ws[1:]:
            x = f'({x} .^. {y} : U32)'
        w(f'def {p}_force(o: {R}) -> U32:')
        w('  match o:')
        w(f'    case {R}{{' + ', '.join('+' + y for y in ws) + f'}}: {x}')
    elif k in ('fixwords', 'bytelist', 'packed', 'packed_elems'):
        w(f'def {p}_force(o: O.Words) -> O.Words & U32: O.words_len(o)')
    elif k == 'bitlist':
        w(f'def {p}_force(o: O.Bits) -> O.Bits & U32: O.bits_size(o)')
    elif k == 'seq':
        e, S, Re, E = s.elem, f'{p}_Seq', s.elem.rep, s.elem.p
        if e.data:
            w(f'def {p}_fo(+k: Nat, +i: U32, +acc: U32, pair: Array<{Re}> & {Re}) -> Array<{Re}> & U32:')
            w('  match k:')
            w('    case 0n:')
            w('      (arr, +v) = pair')
            w(f'      (arr, (acc .^. {E}_force(v) : U32))')
            w('    case 1n+q:')
            w('      (arr, +v) = pair')
            w(f'      {p}_fo(q, (i + 1 : U32), (acc .^. {E}_force(v) : U32), Array.get({Re}, arr, (i + 1 : U32)))')
            w(f'def {p}_fo_fin(+n: U32, pair: Array<{Re}> & U32) -> {S} & U32:')
            w('  (arr, +x) = pair')
            w(f'  ({S}{{arr, n}}, x)')
            w(f'def {p}_fo_nz(empty: Bool, +n: U32, arr: Array<{Re}>) -> {S} & U32:')
            w('  match empty:')
            w(f'    case True{{}}: ({S}{{arr, n}}, 0)')
            w(f'    case False{{}}: {p}_fo_fin(n, {p}_fo(U32.to_nat((n - 1 : U32)), 0, 0, Array.get({Re}, arr, 0)))')
        else:
            w(f'def {p}_fo_back(+i: U32, +acc: U32, arr: Array<{Re}>, pair: {Re} & U32) -> Array<{Re}> & U32:')
            w('  (v, +x) = pair')
            w(f'  (Array.set({Re}, arr, i, v), (acc .^. x : U32))')
            w(f'def {p}_fo_one(+i: U32, +acc: U32, pair: Array<{Re}> & {Re}) -> Array<{Re}> & U32:')
            w('  (arr, v) = pair')
            w(f'  {p}_fo_back(i, acc, arr, {E}_force(v))')
            w(f'def {p}_fo(+k: Nat, +i: U32, pair: Array<{Re}> & U32) -> Array<{Re}> & U32:')
            w('  match k:')
            w('    case 0n: pair')
            w('    case 1n+q:')
            w('      (arr, +acc) = pair')
            w(f'      {p}_fo(q, (i + 1 : U32), {p}_fo_one(i, acc, Array.swap({Re}, arr, i, {E}_default())))')
            w(f'def {p}_fo_fin(+n: U32, pair: Array<{Re}> & U32) -> {S} & U32:')
            w('  (arr, +x) = pair')
            w(f'  ({S}{{arr, n}}, x)')
            w(f'def {p}_fo_nz(empty: Bool, +n: U32, arr: Array<{Re}>) -> {S} & U32:')
            w(f'  {p}_fo_fin(n, {p}_fo(U32.to_nat(n), 0, (arr, 0)))')
        w(f'def {p}_force(o: {S}) -> {S} & U32:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_fo_nz(U32.is_eq(n, 0), n, arr)')
    elif k == 'container':
        if len(s.fields) > GROUP:
            gs = [(f'g{g.k}', g) for g in s.groups]
            emit_force_fields(w, p, R, gs, s.data)
        else:
            emit_force_fields(w, p, R, s.fields, s.data)


def emit_force_fields(w, p, R, F, data):
    names = [f for f, _ in F]
    pat = f'{R}{{' + ', '.join(f'{plus(fs)}{f}' for f, fs in F) + '}'
    if data:
        x = ' .^. '.join(f'{fs.p}_force({f})' for f, fs in F)
        w(f'def {p}_force(o: {R}) -> U32:')
        w('  match o:')
        w(f'    case {pat}: ({x} : U32)' if len(F) > 1 else f'    case {pat}: {F[0][1].p}_force({F[0][0]})')
        return
    lin = [i for i, (f, fs) in enumerate(F) if not fs.data]
    dx = ' .^. '.join(f'{fs.p}_force({f})' for f, fs in F if fs.data) or '0'
    if not lin:
        w(f'def {p}_force(o: {R}) -> {R} & U32:')
        w('  match o:')
        w(f'    case {pat}: ({R}{{' + ', '.join(names) + f'}}, ({dx} : U32))')
        return
    for j in range(len(lin) - 1, -1, -1):
        i = lin[j]
        params = [f'{plus(fs)}{f}: {fs.rep}' for k2, (f, fs) in enumerate(F) if k2 != i]
        w(f'def {p}_fo{j}({", ".join(params)}, +acc: U32, pair: {F[i][1].rep} & U32) -> {R} & U32:')
        w(f'  ({names[i]}, +x) = pair')
        if j == len(lin) - 1:
            w(f'  ({R}{{' + ', '.join(names) + '}, (acc .^. x : U32))')
        else:
            nx = lin[j + 1]
            args = [f for k2, f in enumerate(names) if k2 != nx]
            w(f'  {p}_fo{j + 1}({", ".join(args)}, (acc .^. x : U32), {F[nx][1].p}_force({names[nx]}))')
    args0 = [f for k2, f in enumerate(names) if k2 != lin[0]]
    w(f'def {p}_force(o: {R}) -> {R} & U32:')
    w('  match o:')
    w(f'    case {pat}: {p}_fo0({", ".join(args0)}, ({dx} : U32), {F[lin[0]][1].p}_force({names[lin[0]]}))')


def emit_bool(s, w):
    p = s.p
    w(f'def {p}_default() -> Bool: False{{}}')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: O.rd_bool(buf, off)')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: Bool) -> Array<U32>: O.wbool(out, pos, o)')
    w(f'def {p}_root(h: B.Buf, o: Bool, +seg: U32) -> B.Buf & D.Digest: (h, O.bool_chunk(o))')


def emit_uint(s, w):
    p, n = s.p, s.t.size
    rd = {1: 'O.rd_u8', 2: 'O.rd_u16', 4: 'O.rd_u32'}[n]
    wr = {1: 'O.w8', 2: 'O.w16', 4: 'O.w32'}[n]
    w(f'def {p}_default() -> U32: 0')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & U32: {rd}(buf, off)')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, +o: U32) -> Array<U32>: {wr}(out, pos, o)')
    w(f'def {p}_root(h: B.Buf, +o: U32, +seg: U32) -> B.Buf & D.Digest: (h, O.u32_chunk(o))')


def emit_u64(s, w):
    p = s.p
    w(f'def {p}_default() -> O.U64: O.u64_zero()')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.U64: O.rd_u64(buf, off)')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: O.U64) -> Array<U32>: O.w64(out, pos, o)')
    w(f'def {p}_root(h: B.Buf, o: O.U64, +seg: U32) -> B.Buf & D.Digest: (h, O.u64_chunk(o))')


def emit_rec(s, w):
    """A word record: the bytes as little-endian words, bytes past the end zero."""
    p, R, nw, nb = s.p, s.rep, s.nw, s.nbytes
    ws = [f'w{i}' for i in range(nw)]
    rem = nb % 4
    w(f'def {p}_default() -> {R}: {R}{{' + ', '.join('0' for _ in ws) + '}')
    # read: chain over the words
    for i in range(nw - 1, -1, -1):
        prev = ', '.join(f'+{x}: U32' for x in ws[:i])
        args = (prev + ', ') if prev else ''
        last = (i == nw - 1)
        val = f'O.keep({rem}, x)' if (last and rem) else 'x'
        body_final = f'{R}{{' + ', '.join(ws[:i] + [val]) + '}'
        w(f'def {p}_r{i}(+off: U32, {args}pair: B.Buf & U32) -> B.Buf & {R}:')
        w('  (buf, +x) = pair')
        if last:
            w(f'  (buf, {body_final})')
        else:
            nxt = ', '.join(ws[:i] + ['x'])
            w(f'  {p}_r{i + 1}(off, {nxt}, B.read32(buf, (off + {4 * (i + 1)} : U32)))')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & {R}: {p}_r0(off, B.read32(buf, off))')
    # put
    pat = f'{R}{{' + ', '.join('+' + x for x in ws) + '}'
    expr = 'out'
    for i, x in enumerate(ws):
        expr = f'O.w32({expr}, (pos + {4 * i} : U32), {x})'
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {R}) -> Array<U32>:')
    w('  match o:')
    w(f'    case {pat}: {expr}')
    # root: chunks of eight big-endian words, zero padded, in a complete tree
    nc = chunks_of(nb)
    leaves = []
    for c in range(nc):
        wsw = [f'B.swap32({ws[8 * c + j]})' if 8 * c + j < nw else '0' for j in range(8)]
        leaves.append('D.D{' + ', '.join(wsw) + '}')
    w(f'def {p}_root(h: B.Buf, o: {R}, +seg: U32) -> B.Buf & D.Digest:')
    w('  match o:')
    w(f'    case {pat}: (h, {tree(leaves)})')


def tree(leaves):
    """A complete binary tree over the leaves, padded with the zero chunk.

    Only level-0 padding is supported here (every record has at most 8
    chunks and their counts need no deeper zero subtrees); the generator
    refuses anything else.
    """
    n = len(leaves)
    if n == 1:
        return leaves[0]
    d = log2ceil(n)
    level = list(leaves) + ['D.zero()'] * ((1 << d) - n)
    while len(level) > 1:
        nxt = []
        for i in range(0, len(level), 2):
            a, b = level[i], level[i + 1]
            if a == 'D.zero()' and b == 'D.zero()':
                raise schema.SchemaError('record root needs a zero subtree above level 0')
            nxt.append(f'D.hash_pair({a}, {b})')
        level = nxt
    return level[0]


def emit_words(s, w):
    """Packed little-endian bytes: large byte/bit vectors, byte lists, packed lists."""
    p, t, k = s.p, s.t, s.kind
    if k == 'fixwords':
        nb = t.size if t.kind == 'bytes' else (t.size + 7) // 8
        w(f'def {p}_default() -> O.Words: O.words_new({nb})')
        w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, {nb})')
        depth = log2ceil(chunks_of(nb))
        root = f'O.words_root(h, o, {depth}, seg)'
    elif k == 'bytelist':
        w(f'def {p}_default() -> O.Words: O.words_new(0)')
        w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, len)')
        depth = log2ceil(chunks_of(t.size))
        root = f'O.mix_count(0n, O.words_root(h, o, {depth}, seg))'
    else:
        e = t.elem
        es = e.fixed_size()
        count = t.size
        if t.kind == 'vector':
            w(f'def {p}_default() -> O.Words: O.words_new({count * es})')
            w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, {count * es})')
        else:
            w(f'def {p}_default() -> O.Words: O.words_new(0)')
            w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, len)')
        if k == 'packed':
            depth = log2ceil(chunks_of(count * es))
            core = f'O.words_root(h, o, {depth}, seg)'
        else:
            ew = es // 4
            ed = log2ceil(chunks_of(es))
            depth = log2ceil(count)
            core = f'O.elems_root(h, o, {ew}, {ed}, {depth}, seg)'
        if t.kind == 'vector':
            root = core
        else:
            shift = {1: 0, 2: 1, 4: 2, 8: 3, 16: 4, 32: 5}.get(es)
            if shift is None:
                root = f'{p}_mix({core})'
                w(f'def {p}_mix(pair: B.Buf & (O.Words & D.Digest)) -> B.Buf & (O.Words & D.Digest):')
                w('  (h, r) = pair')
                w('  (o, d) = r')
                w('  match o:')
                w(f'    case O.Words{{ws, +n}}: (h, (O.Words{{ws, n}}, O.mix_len(d, U32.div(n, {es}))))')
            else:
                root = f'O.mix_count({shift}n, {core})'
    w(f'def {p}_size(o: O.Words) -> O.Words & U32: O.words_len(o)')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: O.Words) -> Array<U32> & O.Words: O.put_words(out, pos, o)')
    w(f'def {p}_root(h: B.Buf, o: O.Words, +seg: U32) -> B.Buf & (O.Words & D.Digest): {root}')


def emit_bitlist(s, w):
    p, t = s.p, s.t
    depth = log2ceil(chunks_of((t.size + 7) // 8))
    w(f'def {p}_default() -> O.Bits: O.Bits{{Array.new(U32, 3n, 0), 0}}')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Bits: O.bits_in(buf, off, len)')
    w(f'def {p}_size(o: O.Bits) -> O.Bits & U32: O.bits_size(o)')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: O.Bits) -> Array<U32> & O.Bits: O.put_bits(out, pos, o)')
    w(f'def {p}_root(h: B.Buf, o: O.Bits, +seg: U32) -> B.Buf & (O.Bits & D.Digest): O.bits_root(h, o, {depth}, seg)')


# ---------------------------------------------------------------------------
# Sequences of composite elements: an array of element objects and a count.

def emit_seq(s, w):
    p, t, e = s.p, s.t, s.elem
    R, E = e.rep, e.p
    S = f'{p}_Seq'
    is_list = t.kind == 'list'
    w(f'type {S} is Type:')
    w(f'  {S}{{items: Array<{R}>, n: U32}}')
    # storage: capacity for n elements (at least one slot)
    if e.data:
        w(f'def {p}_fill(+d: Nat) -> Array<{R}>: Array.new({R}, d, {E}_default())')
    else:
        w(f'def {p}_fill(+d: Nat) -> Array<{R}>:')
        w('  match d:')
        w(f'    case 0n: ALeaf{{{E}_default()}}')
        w(f'    case 1n+q: ANode{{{p}_fill(q), {p}_fill(q)}}')
    w(f'def {p}_cap(+n: U32) -> Nat: B.capacity_go(32n, n, 0n)')
    count = t.size
    if is_list:
        w(f'def {p}_default() -> {S}: {S}{{{p}_fill(0n), 0}}')
    else:
        w(f'def {p}_default() -> {S}: {S}{{{p}_fill({p}_cap({count})), {count}}}')
    # element access for the loops: Data elements are read, linear ones swapped out
    if e.data:
        take = f'Array.get({R}, arr, i)'
    else:
        take = f'Array.swap({R}, arr, i, {E}_default())'
    # ---- read ----
    if e.fixed:
        es = e.fsize
        w(f'def {p}_rd(+k: Nat, +i: U32, +off: U32, arr: Array<{R}>, pair: B.Buf & {R}) -> B.Buf & Array<{R}>:')
        w('  match k:')
        w('    case 0n:')
        w(f'      (buf, {plus(e)}v) = pair')
        w(f'      (buf, Array.set({R}, arr, i, v))')
        w('    case 1n+q:')
        w(f'      (buf, {plus(e)}v) = pair')
        w(f'      {p}_rd(q, (i + 1 : U32), off, Array.set({R}, arr, i, v), {E}_read(buf, (off + (i + 1 : U32) * {es} : U32), {es}))')
        w(f'def {p}_rd_fin(+n: U32, pair: B.Buf & Array<{R}>) -> B.Buf & {S}:')
        w('  (buf, arr) = pair')
        w(f'  (buf, {S}{{arr, n}})')
        w(f'def {p}_rd_start(empty: Bool, +off: U32, +n: U32, buf: B.Buf) -> B.Buf & {S}:')
        w('  match empty:')
        w(f'    case True{{}}: (buf, {S}{{{p}_fill(0n), 0}})')
        w(f'    case False{{}}: {p}_rd_fin(n, {p}_rd(U32.to_nat((n - 1 : U32)), 0, off, {p}_fill({p}_cap(n)), {E}_read(buf, off, {es})))')
        if is_list:
            w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & {S}: {p}_rd_start(U32.is_eq(len, 0), off, U32.div(len, {es}), buf)')
        else:
            w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & {S}: {p}_rd_start(False{{}}, off, {count}, buf)')
    else:
        # variable-size elements: offsets table, element i spans [o_i, o_{i+1})
        w(f'def {p}_win_end(+s: U32, pair: B.Buf & U32) -> B.Buf & (U32 & U32):')
        w('  (buf, +e) = pair')
        w('  (buf, (s, e))')
        w(f'def {p}_win_last(last: Bool, +off: U32, +len: U32, +i: U32, +s: U32, buf: B.Buf) -> B.Buf & (U32 & U32):')
        w('  match last:')
        w('    case True{}: (buf, (s, len))')
        w(f'    case False{{}}: {p}_win_end(s, B.read32(buf, (off + 4 * (i + 1 : U32) : U32)))')
        w(f'def {p}_win_start(+off: U32, +len: U32, +i: U32, +n: U32, pair: B.Buf & U32) -> B.Buf & (U32 & U32):')
        w('  (buf, +s) = pair')
        w(f'  {p}_win_last(U32.is_eq((i + 1 : U32), n), off, len, i, s, buf)')
        w(f'def {p}_elem_win(+off: U32, +s: U32, +e: U32, buf: B.Buf) -> B.Buf & {R}: {E}_read(buf, (off + s : U32), (e - s : U32))')
        w(f'def {p}_elem(+off: U32, pair: B.Buf & (U32 & U32)) -> B.Buf & {R}:')
        w('  (buf, se) = pair')
        w('  (s, e) = se')
        w(f'  {p}_elem_win(off, s, e, buf)')
        w(f'def {p}_rv(+k: Nat, +i: U32, +off: U32, +len: U32, +n: U32, arr: Array<{R}>, pair: B.Buf & {R}) -> B.Buf & Array<{R}>:')
        w('  match k:')
        w('    case 0n:')
        w(f'      (buf, {plus(e)}v) = pair')
        w(f'      (buf, Array.set({R}, arr, i, v))')
        w('    case 1n+q:')
        w(f'      (buf, {plus(e)}v) = pair')
        w(f'      {p}_rv(q, (i + 1 : U32), off, len, n, Array.set({R}, arr, i, v), {p}_elem(off, {p}_win_start(off, len, (i + 1 : U32), n, B.read32(buf, (off + 4 * (i + 1 : U32) : U32)))))')
        w(f'def {p}_rv_fin(+n: U32, pair: B.Buf & Array<{R}>) -> B.Buf & {S}:')
        w('  (buf, arr) = pair')
        w(f'  (buf, {S}{{arr, n}})')
        w(f'def {p}_rv_count(+off: U32, +len: U32, pair: B.Buf & U32) -> B.Buf & {S}:')
        w('  (buf, +first) = pair')
        w(f'  {p}_rv_fin(U32.shrn(first, 2n), {p}_rv(U32.to_nat((U32.shrn(first, 2n) - 1 : U32)), 0, off, len, U32.shrn(first, 2n), {p}_fill({p}_cap(U32.shrn(first, 2n))), {p}_elem(off, {p}_win_start(off, len, 0, U32.shrn(first, 2n), B.read32(buf, off)))))')
        if is_list:
            w(f'def {p}_read_nz(empty: Bool, buf: B.Buf, +off: U32, +len: U32) -> B.Buf & {S}:')
            w('  match empty:')
            w(f'    case True{{}}: (buf, {S}{{{p}_fill(0n), 0}})')
            w(f'    case False{{}}: {p}_rv_count(off, len, B.read32(buf, off))')
            w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & {S}: {p}_read_nz(U32.is_eq(len, 0), buf, off, len)')
        else:
            w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & {S}: {p}_rv_count(off, len, B.read32(buf, off))')
    # ---- size, put ----
    if e.fixed:
        es = e.fsize
        w(f'def {p}_size(o: {S}) -> {S} & U32:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: ({S}{{arr, n}}, (n * {es} : U32))')
        if e.data:
            w(f'def {p}_pt(+k: Nat, +i: U32, +pos: U32, out: Array<U32>, pair: Array<{R}> & {R}) -> Array<U32> & Array<{R}>:')
            w('  match k:')
            w('    case 0n:')
            w('      (arr, +v) = pair')
            w(f'      ({E}_put(out, (pos + i * {es} : U32), v), arr)')
            w('    case 1n+q:')
            w('      (arr, +v) = pair')
            w(f'      {p}_pt(q, (i + 1 : U32), pos, {E}_put(out, (pos + i * {es} : U32), v), Array.get({R}, arr, (i + 1 : U32)))')
            w(f'def {p}_pt_fin(+n: U32, pair: Array<U32> & Array<{R}>) -> Array<U32> & {S}:')
            w('  (out, arr) = pair')
            w(f'  (out, {S}{{arr, n}})')
            w(f'def {p}_pt_nz(empty: Bool, +pos: U32, +n: U32, out: Array<U32>, arr: Array<{R}>) -> Array<U32> & {S}:')
            w('  match empty:')
            w(f'    case True{{}}: (out, {S}{{arr, n}})')
            w(f'    case False{{}}: {p}_pt_fin(n, {p}_pt(U32.to_nat((n - 1 : U32)), 0, pos, out, Array.get({R}, arr, 0)))')
        else:
            # linear fixed-size elements (a Deposit's proof is packed words)
            w(f'def {p}_pt_back(+i: U32, arr: Array<{R}>, pair: Array<U32> & {R}) -> Array<U32> & Array<{R}>:')
            w('  (out, v) = pair')
            w(f'  (out, Array.set({R}, arr, i, v))')
            w(f'def {p}_pt_one(+i: U32, +pos: U32, out: Array<U32>, pair: Array<{R}> & {R}) -> Array<U32> & Array<{R}>:')
            w('  (arr, v) = pair')
            w(f'  {p}_pt_back(i, arr, {E}_put(out, (pos + i * {es} : U32), v))')
            w(f'def {p}_pt(+k: Nat, +i: U32, +pos: U32, pair: Array<U32> & Array<{R}>) -> Array<U32> & Array<{R}>:')
            w('  match k:')
            w('    case 0n: pair')
            w('    case 1n+q:')
            w('      (out, arr) = pair')
            w(f'      {p}_pt(q, (i + 1 : U32), pos, {p}_pt_one(i, pos, out, Array.swap({R}, arr, i, {E}_default())))')
            w(f'def {p}_pt_fin(+n: U32, pair: Array<U32> & Array<{R}>) -> Array<U32> & {S}:')
            w('  (out, arr) = pair')
            w(f'  (out, {S}{{arr, n}})')
            w(f'def {p}_pt_nz(empty: Bool, +pos: U32, +n: U32, out: Array<U32>, arr: Array<{R}>) -> Array<U32> & {S}:')
            w(f'  {p}_pt_fin(n, {p}_pt(U32.to_nat(n), 0, pos, (out, arr)))')
    else:
        # variable-size elements: element sizes first (for the offsets), then
        # offsets and elements in one pass tracking the running offset.
        w(f'def {p}_sz_back(+i: U32, +acc: U32, arr: Array<{R}>, pair: {R} & U32) -> Array<{R}> & U32:')
        w('  (v, +m) = pair')
        w(f'  (Array.set({R}, arr, i, v), (acc + m : U32))')
        w(f'def {p}_sz_one(+i: U32, +acc: U32, pair: Array<{R}> & {R}) -> Array<{R}> & U32:')
        w('  (arr, v) = pair')
        w(f'  {p}_sz_back(i, acc, arr, {E}_size(v))')
        w(f'def {p}_sz(+k: Nat, +i: U32, pair: Array<{R}> & U32) -> Array<{R}> & U32:')
        w('  match k:')
        w('    case 0n: pair')
        w('    case 1n+q:')
        w('      (arr, +acc) = pair')
        w(f'      {p}_sz(q, (i + 1 : U32), {p}_sz_one(i, acc, Array.swap({R}, arr, i, {E}_default())))')
        w(f'def {p}_sz_fin(+n: U32, pair: Array<{R}> & U32) -> {S} & U32:')
        w('  (arr, +m) = pair')
        w(f'  ({S}{{arr, n}}, (4 * n + m : U32))')
        w(f'def {p}_size(o: {S}) -> {S} & U32:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_sz_fin(n, {p}_sz(U32.to_nat(n), 0, (arr, 0)))')
        # put: state (out, (arr, cur)); element i: size it, write its offset
        # (cur) and the element at pos + cur, put it back, advance cur.
        w(f'def {p}_pv_put(+i: U32, +next: U32, arr: Array<{R}>, pair: Array<U32> & {R}) -> Array<U32> & (Array<{R}> & U32):')
        w('  (out, v) = pair')
        w(f'  (out, (Array.set({R}, arr, i, v), next))')
        w(f'def {p}_pv_placed(+pos: U32, +cur: U32, out: Array<U32>, arr: Array<{R}>, +i: U32, pair: {R} & U32) -> Array<U32> & (Array<{R}> & U32):')
        w('  (v, +m) = pair')
        w(f'  {p}_pv_put(i, (cur + m : U32), arr, {E}_put(out, (pos + cur : U32), v))')
        w(f'def {p}_pv_one(+i: U32, +pos: U32, +cur: U32, out: Array<U32>, pair: Array<{R}> & {R}) -> Array<U32> & (Array<{R}> & U32):')
        w('  (arr, v) = pair')
        w(f'  {p}_pv_placed(pos, cur, O.w32(out, (pos + 4 * i : U32), cur), arr, i, {E}_size(v))')
        w(f'def {p}_pv(+k: Nat, +i: U32, +pos: U32, pair: Array<U32> & (Array<{R}> & U32)) -> Array<U32> & (Array<{R}> & U32):')
        w('  match k:')
        w('    case 0n: pair')
        w('    case 1n+q:')
        w('      (out, st) = pair')
        w('      (arr, cur) = st')
        w(f'      {p}_pv(q, (i + 1 : U32), pos, {p}_pv_one(i, pos, cur, out, Array.swap({R}, arr, i, {E}_default())))')
        w(f'def {p}_pv_fin(+n: U32, pair: Array<U32> & (Array<{R}> & U32)) -> Array<U32> & {S}:')
        w('  (out, st) = pair')
        w('  (arr, cur) = st')
        w(f'  (out, {S}{{arr, n}})')
        w(f'def {p}_pt_nz(empty: Bool, +pos: U32, +n: U32, out: Array<U32>, arr: Array<{R}>) -> Array<U32> & {S}:')
        w(f'  {p}_pv_fin(n, {p}_pv(U32.to_nat(n), 0, pos, (out, (arr, (4 * n : U32)))))')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {S}) -> Array<U32> & {S}:')
    w('  match o:')
    w(f'    case {S}{{arr, +n}}: {p}_pt_nz(U32.is_eq(n, 0), pos, n, out, arr)')
    # ---- root ----
    depth = log2ceil(t.size)
    w(f'def {p}_rt_push(+i: U32, +seg: U32, arr: Array<{R}>, pair: B.Buf & ({R} & D.Digest)) -> B.Buf & Array<{R}>:')
    w('  (h, r) = pair')
    w('  (v, d) = r')
    w(f'  (M.push_leaf(i, seg, d, h), Array.set({R}, arr, i, v))')
    if e.data:
        w(f'def {p}_rt_one(+i: U32, +seg: U32, h: B.Buf, pair: Array<{R}> & {R}) -> B.Buf & Array<{R}>:')
        w('  (arr, +v) = pair')
        w(f'  {p}_rt_leaf(i, seg, arr, {E}_root(h, v, (seg + 64 : U32)))')
        w(f'def {p}_rt_leaf(+i: U32, +seg: U32, arr: Array<{R}>, pair: B.Buf & D.Digest) -> B.Buf & Array<{R}>:')
        w('  (h, d) = pair')
        w(f'  (M.push_leaf(i, seg, d, h), arr)')
    else:
        w(f'def {p}_rt_one(+i: U32, +seg: U32, h: B.Buf, pair: Array<{R}> & {R}) -> B.Buf & Array<{R}>:')
        w('  (arr, v) = pair')
        w(f'  {p}_rt_push(i, seg, arr, {E}_root(h, v, (seg + 64 : U32)))')
    w(f'def {p}_rt(+k: Nat, +i: U32, +seg: U32, pair: B.Buf & Array<{R}>) -> B.Buf & Array<{R}>:')
    w('  match k:')
    w('    case 0n: pair')
    w('    case 1n+q:')
    w('      (h, arr) = pair')
    w(f'      {p}_rt(q, (i + 1 : U32), seg, {p}_rt_one(i, seg, h, {take}))')
    w(f'def {p}_rt_fin(+n: U32, +seg: U32, pair: B.Buf & Array<{R}>) -> B.Buf & ({S} & D.Digest):')
    w('  (h, arr) = pair')
    w(f'  {p}_rt_close(n, arr, M.close({depth}, n, seg, h))')
    w(f'def {p}_rt_close(+n: U32, arr: Array<{R}>, pair: B.Buf & D.Digest) -> B.Buf & ({S} & D.Digest):')
    w('  (h, d) = pair')
    mixed = 'O.mix_len(d, n)' if is_list else 'd'
    w(f'  (h, ({S}{{arr, n}}, {mixed}))')
    w(f'def {p}_root(h: B.Buf, o: {S}, +seg: U32) -> B.Buf & ({S} & D.Digest):')
    w('  match o:')
    w(f'    case {S}{{arr, +n}}: {p}_rt_fin(n, seg, {p}_rt(U32.to_nat(n), 0, seg, (h, arr)))')


def emit_seq_cache(s, w):
    """A list of objects with a cached Merkle tree over its elements.

    The cache holds one digest per node of a heap-shaped tree over the element
    array's capacity: node 1 is its root, node k's children are 2k and 2k+1,
    element i is leaf node cap+i. Alongside it the cache keeps the range of
    element indices whose leaves have changed since the last root, which is
    exactly the set of stale nodes: node k at level L is stale precisely when
    it is an ancestor of one of those leaves. Hashing the list recomputes that
    range and its ancestors, level by level, and leaves every other subtree's
    digest alone; a fresh cache starts with the whole range dirty, so its first
    root builds the tree. Writing element i or appending one only widens the
    range - no hashing - so the next root re-hashes the changed element and the
    log(capacity) nodes above it.

    Leaves past the length hash as the zero chunk, and the levels between the
    capacity and the list's declared limit are folded in with the zero subtree
    roots, which is what the SSZ limit depth means; the length is mixed in at
    the end, so appends change it without touching the tree above the new leaf.

    Appending past the capacity doubles the element array and starts a fresh
    tree, so an append is amortised constant storage and that one append pays
    for the rebuild. Nothing here is on the decode path: a caller opts in with
    _cache and leaves with _uncache.
    """
    p, t, e = s.p, s.t, s.elem
    R, E, S, C, TS = e.rep, e.p, f'{p}_Seq', f'{p}_Cached', f'{p}_TS'
    depth = log2ceil(t.size)
    take = f'Array.get({R}, arr, i)' if e.data else f'Array.swap({R}, arr, i, {E}_default())'
    w(f'type {C} is Type:')
    w(f'  {C}{{items: Array<{R}>, n: U32, d: Nat, nodes: Array<D.Digest>, lo: U32, hi: U32}}')
    w(f'type {TS} is Type:')
    w(f'  {TS}{{h: B.Buf, items: Array<{R}>, nodes: Array<D.Digest>}}')
    w(f'def {p}_dfill(+d: Nat) -> Array<D.Digest>: Array.new(D.Digest, d, D.zero())')
    w(f'def {p}_cache_at(arr: Array<{R}>, +n: U32, +d: Nat) -> {C}:')
    w(f'  {C}{{arr, n, d, {p}_dfill(1n+d), 0, (O.pow2u(d) - 1 : U32)}}')
    w(f'def {p}_cache(o: {S}) -> {C}:')
    w('  match o:')
    w(f'    case {S}{{arr, +n}}: {p}_cache_at(arr, n, {p}_cap(n))')
    w(f'def {p}_uncache(c: {C}) -> {S}:')
    w('  match c:')
    w(f'    case {C}{{arr, +n, +d, nodes, +lo, +hi}}: {S}{{arr, n}}')
    w(f'def {p}_clen(c: {C}) -> {C} & U32:')
    w('  match c:')
    w(f'    case {C}{{arr, +n, +d, nodes, +lo, +hi}}: ({C}{{arr, n, d, nodes, lo, hi}}, n)')
    # indexed read and write through the cache
    w(f'def {p}_cget(c: {C}, +i: U32) -> {C} & Maybe<&1, {R}>:')
    w('  match c:')
    w(f'    case {C}{{arr, +n, +d, nodes, +lo, +hi}}: {p}_cget_in(U32.is_lt(i, n), arr, n, d, nodes, lo, hi, i)')
    w(f'def {p}_cget_in(inside: Bool, arr: Array<{R}>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, +i: U32) -> {C} & Maybe<&1, {R}>:')
    w('  match inside:')
    w(f'    case True{{}}: {p}_ctook(n, d, nodes, lo, hi, {take})')
    w(f'    case False{{}}: ({C}{{arr, n, d, nodes, lo, hi}}, None{{}})')
    w(f'def {p}_ctook(+n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, pair: Array<{R}> & {R}) -> {C} & Maybe<&1, {R}>:')
    w(f'  (arr, {plus(e)}v) = pair')
    w(f'  ({C}{{arr, n, d, nodes, lo, hi}}, Some{{v}})')
    w(f'def {p}_cset(c: {C}, +i: U32, v: {R}) -> {C} & Bool:')
    w('  match c:')
    w(f'    case {C}{{arr, +n, +d, nodes, +lo, +hi}}: {p}_cset_in(U32.is_lt(i, n), arr, n, d, nodes, lo, hi, i, v)')
    w(f'def {p}_cset_in(ok: Bool, arr: Array<{R}>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, +i: U32, v: {R}) -> {C} & Bool:')
    w('  match ok:')
    w(f'    case True{{}}: ({C}{{Array.set({R}, arr, i, v), n, d, nodes,'
      ' O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)}, True{})')
    w(f'    case False{{}}: ({C}{{arr, n, d, nodes, lo, hi}}, False{{}})')
    w(f'def {p}_capp(c: {C}, v: {R}) -> {C} & Bool:')
    w('  match c:')
    w(f'    case {C}{{arr, +n, +d, nodes, +lo, +hi}}: {p}_capp_in({within("(n + 1 : U32)", t.size)}, arr, n, d, nodes, lo, hi, v)')
    w(f'def {p}_capp_in(ok: Bool, arr: Array<{R}>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, v: {R}) -> {C} & Bool:')
    w('  match ok:')
    w(f'    case True{{}}: ({p}_capp_fit(U32.is_lt(n, O.pow2u(d)), arr, n, d, nodes, lo, hi, v), True{{}})')
    w(f'    case False{{}}: ({C}{{arr, n, d, nodes, lo, hi}}, False{{}})')
    w(f'def {p}_capp_fit(fits: Bool, arr: Array<{R}>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, v: {R}) -> {C}:')
    w('  match fits:')
    w(f'    case True{{}}: {C}{{Array.set({R}, arr, n, v), (n + 1 : U32), d, nodes,'
      ' O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n)}')
    w(f'    case False{{}}: {C}{{Array.set({R}, {p}_room(arr, n), n, v), (n + 1 : U32), 1n+d,'
      f' {p}_dfill(2n+d), 0, (O.pow2u(1n+d) - 1 : U32)}}')
    # ---- the sweep: recompute the stale leaves, then their ancestors ----
    w(f'def {p}_ts_store(ts: {TS}, +k: U32, +dg: D.Digest) -> {TS}:')
    w('  match ts:')
    w(f'    case {TS}{{h, arr, nodes}}: {TS}{{h, arr, Array.set(D.Digest, nodes, k, dg)}}')
    if e.data:
        w(f'def {p}_leaf_fin(+k: U32, arr: Array<{R}>, nodes: Array<D.Digest>, pr: B.Buf & D.Digest) -> {TS}:')
        w('  (h, +dg) = pr')
        w(f'  {p}_ts_store({TS}{{h, arr, nodes}}, k, dg)')
        w(f'def {p}_leaf_go(+k: U32, +seg: U32, nodes: Array<D.Digest>, h: B.Buf, pr: Array<{R}> & {R}) -> {TS}:')
        w('  (arr, +v) = pr')
        w(f'  {p}_leaf_fin(k, arr, nodes, {E}_root(h, v, (seg + 64 : U32)))')
        hash_args = 'k, seg, nodes, h, '
    else:
        w(f'def {p}_leaf_put(+k: U32, h: B.Buf, arr: Array<{R}>, nodes: Array<D.Digest>, +dg: D.Digest) -> {TS}:')
        w(f'  {p}_ts_store({TS}{{h, arr, nodes}}, k, dg)')
        w(f'def {p}_leaf_fin(+k: U32, +i: U32, arr: Array<{R}>, nodes: Array<D.Digest>, pr: B.Buf & ({R} & D.Digest)) -> {TS}:')
        w('  (h, r) = pr')
        w('  (v, dg) = r')
        w(f'  {p}_leaf_put(k, h, Array.set({R}, arr, i, v), nodes, dg)')
        w(f'def {p}_leaf_go(+k: U32, +i: U32, +seg: U32, nodes: Array<D.Digest>, h: B.Buf, pr: Array<{R}> & {R}) -> {TS}:')
        w('  (arr, v) = pr')
        w(f'  {p}_leaf_fin(k, i, arr, nodes, {E}_root(h, v, (seg + 64 : U32)))')
        hash_args = 'k, i, seg, nodes, h, '
    w(f'def {p}_leaf_hash(+k: U32, +i: U32, +seg: U32, ts: {TS}) -> {TS}:')
    w('  match ts:')
    w(f'    case {TS}{{h, arr, nodes}}: {p}_leaf_go({hash_args}{take})')
    w(f'def {p}_leaf_step(inside: Bool, +k: U32, +i: U32, +seg: U32, ts: {TS}) -> {TS}:')
    w('  match inside:')
    w(f'    case True{{}}: {p}_leaf_hash(k, i, seg, ts)')
    w(f'    case False{{}}: {p}_ts_store(ts, k, D.zero())')
    w(f'def {p}_leaves(+q: Nat, +i: U32, +n: U32, +seg: U32, +cap: U32, ts: {TS}) -> {TS}:')
    w('  match q:')
    w('    case 0n: ts')
    w('    case 1n+r:')
    w(f'      {p}_leaves(r, (i + 1 : U32), n, seg, cap,'
      f' {p}_leaf_step(U32.is_lt(i, n), (cap + i : U32), i, seg, ts))')
    # one internal node: the hash of its two children, both already up to date
    w(f'def {p}_node_fin(+j: U32, h: B.Buf, arr: Array<{R}>, +dl: D.Digest, pr: Array<D.Digest> & D.Digest) -> {TS}:')
    w('  (nodes, +dr) = pr')
    w(f'  {p}_ts_store({TS}{{h, arr, nodes}}, j, D.hash_pair(dl, dr))')
    w(f'def {p}_node_go(+j: U32, h: B.Buf, arr: Array<{R}>, pr: Array<D.Digest> & D.Digest) -> {TS}:')
    w('  (nodes, +dl) = pr')
    w(f'  {p}_node_fin(j, h, arr, dl, Array.get(D.Digest, nodes, (2 * j + 1 : U32)))')
    w(f'def {p}_node_step(+j: U32, ts: {TS}) -> {TS}:')
    w('  match ts:')
    w(f'    case {TS}{{h, arr, nodes}}: {p}_node_go(j, h, arr, Array.get(D.Digest, nodes, (2 * j : U32)))')
    w(f'def {p}_level(+q: Nat, +j: U32, ts: {TS}) -> {TS}:')
    w('  match q:')
    w('    case 0n: ts')
    w(f'    case 1n+r: {p}_level(r, (j + 1 : U32), {p}_node_step(j, ts))')
    w(f'def {p}_levels(+L: Nat, +klo: U32, +khi: U32, ts: {TS}) -> {TS}:')
    w('  match L:')
    w('    case 0n: ts')
    w('    case 1n+q:')
    w(f'      {p}_levels(q, U32.shrn(klo, 1n), U32.shrn(khi, 1n),'
      f' {p}_level(U32.to_nat((U32.shrn(khi, 1n) - U32.shrn(klo, 1n) + 1 : U32)), U32.shrn(klo, 1n), ts))')
    w(f'def {p}_sweep(+d: Nat, +lo: U32, +hi: U32, +n: U32, +seg: U32, ts: {TS}) -> {TS}:')
    w(f'  {p}_levels(d, (O.pow2u(d) + lo : U32), (O.pow2u(d) + hi : U32),'
      f' {p}_leaves(U32.to_nat((hi - lo + 1 : U32)), lo, n, seg, O.pow2u(d), ts))')
    w(f'def {p}_sweep_pick(some: Bool, +d: Nat, +lo: U32, +hi: U32, +n: U32, +seg: U32, ts: {TS}) -> {TS}:')
    w('  match some:')
    w(f'    case True{{}}: {p}_sweep(d, lo, hi, n, seg, ts)')
    w('    case False{}: ts')
    # the levels between the capacity and the list limit are zero subtrees
    w(f'def {p}_pad_go(+k: Nat, +lvl: U32, +r: D.Digest, pr: B.Buf & D.Digest) -> B.Buf & D.Digest:')
    w('  match k:')
    w('    case 0n:')
    w('      (h, +z) = pr')
    w('      (h, r)')
    w('    case 1n+q:')
    w('      (h, +z) = pr')
    w(f'      {p}_pad_go(q, (lvl + 1 : U32), D.hash_pair(r, z), O.zero(h, (lvl + 1 : U32)))')
    w(f'def {p}_croot_fin(+n: U32, +d: Nat, arr: Array<{R}>, nodes: Array<D.Digest>, pr: B.Buf & D.Digest) -> B.Buf & ({C} & D.Digest):')
    w('  (h, +r) = pr')
    w(f'  (h, ({C}{{arr, n, d, nodes, 4294967295, 0}}, O.mix_len(r, n)))')
    w(f'def {p}_croot_pad(+n: U32, +d: Nat, arr: Array<{R}>, nodes: Array<D.Digest>, h: B.Buf, +r: D.Digest) -> B.Buf & ({C} & D.Digest):')
    w(f'  {p}_croot_fin(n, d, arr, nodes,'
      f' {p}_pad_go(Nat.sub({depth}n, d), O.nat_u32(d), r, O.zero(h, O.nat_u32(d))))')
    w(f'def {p}_croot_read(+n: U32, +d: Nat, h: B.Buf, arr: Array<{R}>, pr: Array<D.Digest> & D.Digest) -> B.Buf & ({C} & D.Digest):')
    w('  (nodes, +r) = pr')
    w(f'  {p}_croot_pad(n, d, arr, nodes, h, r)')
    w(f'def {p}_croot_top(+n: U32, +d: Nat, ts: {TS}) -> B.Buf & ({C} & D.Digest):')
    w('  match ts:')
    w(f'    case {TS}{{h, arr, nodes}}: {p}_croot_read(n, d, h, arr, Array.get(D.Digest, nodes, 1))')
    w(f'def {p}_cached_root(h: B.Buf, c: {C}, +seg: U32) -> B.Buf & ({C} & D.Digest):')
    w('  match c:')
    w(f'    case {C}{{arr, +n, +d, nodes, +lo, +hi}}:')
    w(f'      {p}_croot_top(n, d, {p}_sweep_pick(U32.is_le(lo, hi), d, lo, hi, n, seg, {TS}{{h, arr, nodes}}))')
    w('')


def fix_seq_order(text):
    return text


# ---------------------------------------------------------------------------
# Containers.

GROUP = 8                 # a container with more fields is split into groups of 8 consecutive
                          # fields, each exactly a depth-3 subtree of its Merkle tree


class GroupShape:
    """Fields [8k, 8k + 8) of a wide container, kept in one sub-record.

    The group's bytes are part of the container's flat layout: its fixed
    fields sit at the container's header offsets and its variable fields'
    offsets are relative to the container start. So its reader takes the
    container window plus `vend`, the end of its last variable field (the
    next group's first variable offset, or the window end); its writer takes
    and returns the running variable-data offset `voff`.
    """

    def __init__(self, outer, k, fields, hoff):
        self.outer, self.k = outer, k
        self.p = f'{outer.p}_g{k}'
        self.kind = 'group'
        self.fields = fields          # [(name, shape)]
        self.hoff = hoff              # container-relative header offsets
        self.t = None
        self.fixed = all(fs.fixed for _, fs in fields)
        self.fsize = None
        self.data = all(fs.data for _, fs in fields)
        self.rep = self.p

    def flat(self):
        return sum(fs.flat() for _, fs in self.fields)


def container_layout(fields):
    hoff, o = [], 0
    for f, fs in fields:
        hoff.append(o)
        o += fs.fsize if fs.fixed else 4
    return hoff, o


def emit_container(s, w):
    F = s.fields
    hoff, fixed_part = container_layout(F)
    if len(F) <= GROUP:
        emit_fieldset(s, w, s.p, s.t.name, F, hoff, fixed_part, 'plain', s.data)
        emit_fieldset_root(s, w, s.p, s.t.name, F, 'plain', s.data)
        emit_fields_access(w, s.p, s.t.name, F)
        return
    groups = []
    for k in range(0, len(F), GROUP):
        g = GroupShape(s, k // GROUP, F[k:k + GROUP], hoff[k:k + GROUP])
        groups.append(g)
        emit_fieldset(g, w, g.p, g.p, g.fields, g.hoff, fixed_part, 'group', g.data)
        emit_fieldset_root(g, w, g.p, g.p, g.fields, 'group', g.data)
        emit_group_force(g, w)
        emit_fields_access(w, g.p, g.p, g.fields)
        w('')
    s.groups = groups
    emit_wide(s, w, groups, hoff, fixed_part)
    emit_wide_access(w, s.p, s.t.name, groups)


def emit_fieldset(s, w, p, R, F, hoff, fixed_part, mode, data):
    """Record type, default, read, size and put of a plain container or a group."""
    names = [f for f, _ in F]
    kind = 'Data' if data else 'Type'
    w(f'type {R} is {kind}:')
    w(f'  {R}{{' + ', '.join(f'{f}: {fs.rep}' for f, fs in F) + '}')
    w(f'def {p}_default() -> {R}: {R}{{' + ', '.join(f'{fs.p}_default()' for f, fs in F) + '}')
    var = [i for i, (f, fs) in enumerate(F) if not fs.fixed]
    extra = ', +vend: U32' if mode == 'group' else ''
    xarg = ', vend' if mode == 'group' else ''
    # ---- read: offsets of the variable fields, then each field ----
    steps = [('off', i) for i in var] + [('field', i) for i in range(len(F))]

    def btype(st):
        return 'U32' if st[0] == 'off' else F[st[1]][1].rep

    def bname(st):
        return f'o_{names[st[1]]}' if st[0] == 'off' else names[st[1]]

    def bplus(st):
        return '+' if st[0] == 'off' or F[st[1]][1].data else ''

    def window(i):
        fs = F[i][1]
        if fs.fixed:
            return f'(off + {hoff[i]} : U32)', str(fs.fsize)
        j = var.index(i)
        start = f'o_{names[i]}'
        end = f'o_{names[var[j + 1]]}' if j + 1 < len(var) else ('vend' if mode == 'group' else 'len')
        return f'(off + {start} : U32)', f'({end} - {start} : U32)'

    def call(st):
        if st[0] == 'off':
            return f'B.read32(buf, (off + {hoff[st[1]]} : U32))'
        a, n = window(st[1])
        return f'{F[st[1]][1].p}_read(buf, {a}, {n})'

    for k in range(len(steps) - 1, -1, -1):
        st = steps[k]
        params = ''.join(f'{bplus(x)}{bname(x)}: {btype(x)}, ' for x in steps[:k])
        w(f'def {p}_rd{k}(+off: U32, +len: U32{extra}, {params}pair: B.Buf & {btype(st)}) -> B.Buf & {R}:')
        w(f'  (buf, {bplus(st)}{bname(st)}) = pair')
        if k == len(steps) - 1:
            w(f'  (buf, {R}{{' + ', '.join(names) + '})')
        else:
            args = ', '.join(bname(x) for x in steps[:k + 1])
            w(f'  {p}_rd{k + 1}(off, len{xarg}, {args}, {call(steps[k + 1])})')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32{extra}) -> B.Buf & {R}: {p}_rd0(off, len{xarg}, {call(steps[0])})')
    pat = f'{R}{{' + ', '.join(f'{plus(fs)}{f}' for f, fs in F) + '}'

    def data_writes(expr, offs):
        for i, (f, fs) in enumerate(F):
            if fs.data:
                expr = f'{fs.p}_put({expr}, (pos + {hoff[i]} : U32), {f})'
        for i in var:
            expr = f'O.w32({expr}, (pos + {hoff[i]} : U32), {offs(i)})'
        return expr

    if data:
        # every field Data and fixed: a pure write
        if mode == 'group':
            w(f'def {p}_put(out: Array<U32>, +pos: U32, +voff: U32, o: {R}) -> Array<U32>:')
        else:
            w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {R}) -> Array<U32>:')
        w('  match o:')
        w(f'    case {pat}: {data_writes("out", None)}')
        return
    lin = [i for i, (f, fs) in enumerate(F) if not fs.data]
    # ---- size: the variable fields' sizes (plus the fixed part for a container) ----
    base = '0' if mode == 'group' else str(fixed_part)
    if var:
        for j in range(len(var) - 1, -1, -1):
            i = var[j]
            others = [f'{plus(fs)}{f}: {fs.rep}' for k2, (f, fs) in enumerate(F) if k2 != i and (k2 not in var or var.index(k2) > j)]
            done = [f'{names[var[q]]}: {F[var[q]][1].rep}' for q in range(j)]
            w(f'def {p}_sz{j}({", ".join(others + done + ["+acc: U32"])}, pair: {F[i][1].rep} & U32) -> {R} & U32:')
            w(f'  ({names[i]}, +m) = pair')
            if j == len(var) - 1:
                w(f'  ({R}{{' + ', '.join(names) + f'}}, (acc + m : U32))')
            else:
                nxt = var[j + 1]
                others2 = [f for k2, (f, fs) in enumerate(F) if k2 != nxt and (k2 not in var or var.index(k2) > j + 1)]
                done2 = [names[var[q]] for q in range(j + 1)]
                w(f'  {p}_sz{j + 1}({", ".join(others2 + done2)}, (acc + m : U32), {F[nxt][1].p}_size({names[nxt]}))')
        first = var[0]
        others0 = [f for k2, f in enumerate(names) if k2 != first]
        w(f'def {p}_size(o: {R}) -> {R} & U32:')
        w('  match o:')
        w(f'    case {pat}: {p}_sz0({", ".join(others0)}, {base}, {F[first][1].p}_size({names[first]}))')
    else:
        w(f'def {p}_size(o: {R}) -> {R} & U32: (o, {base})')
    # ---- put: sizes of the variable fields first (for the offsets), then
    # the data fields and offsets, then each linear field ----
    psteps = [('size', i) for i in var] + [('put', i) for i in lin]
    vstart = 'voff' if mode == 'group' else str(fixed_part)

    def offs(i):
        parts = [vstart] + [f's_{names[v]}' for v in var if v < i]
        return '(' + ' + '.join(parts) + ' : U32)' if len(parts) > 1 else parts[0]

    def pos_of(i):
        if F[i][1].fixed:
            return f'(pos + {hoff[i]} : U32)'
        return f'(pos + {offs(i)} : U32)'

    vparam = ['+voff: U32'] if mode == 'group' else []
    vargs = ['voff'] if mode == 'group' else []
    if mode == 'group':
        rtype = f'Array<U32> & ({R} & U32)'
        total = '(' + ' + '.join([vstart] + [f's_{names[v]}' for v in var]) + ' : U32)' if var else vstart
        final = f'(out, ({R}{{' + ', '.join(names) + f'}}, {total}))'
    else:
        rtype = f'Array<U32> & {R}'
        final = f'(out, {R}{{' + ', '.join(names) + '})'
    if not psteps:
        if mode == 'group':
            w(f'def {p}_put(out: Array<U32>, +pos: U32, +voff: U32, o: {R}) -> {rtype}:')
        else:
            w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {R}) -> {rtype}:')
        w('  match o:')
        w(f'    case {pat}: ({data_writes("out", offs)}, ' + (f'({R}{{' + ', '.join(names) + '}, voff))' if mode == 'group' else f'{R}{{' + ', '.join(names) + '})'))
        return
    total_steps = len(psteps)
    for k in range(total_steps - 1, -1, -1):
        kind_, i = psteps[k]
        params = ['+pos: U32'] + vparam
        for i2, (f, fs) in enumerate(F):
            if i2 == i:
                continue
            params.append(f'{plus(fs)}{f}: {fs.rep}')
        known = [f'+s_{names[v]}: U32' for v in var if ('size', v) in psteps[:k]]
        if kind_ == 'size':
            w(f'def {p}_pw{k}({", ".join(params + known + ["out: Array<U32>"])}, pair: {F[i][1].rep} & U32) -> {rtype}:')
            w(f'  ({names[i]}, +s_{names[i]}) = pair')
        else:
            w(f'def {p}_pw{k}({", ".join(params + known)}, pair: Array<U32> & {F[i][1].rep}) -> {rtype}:')
            w(f'  (out, {names[i]}) = pair')
        if k == total_steps - 1:
            w(f'  {final}')
            continue
        nk, ni = psteps[k + 1]
        held = [f for i2, f in enumerate(names) if i2 != ni]
        known2 = [f's_{names[v]}' for v in var if ('size', v) in psteps[:k + 1]]
        if nk == 'size':
            w(f'  {p}_pw{k + 1}({", ".join(["pos"] + vargs + held + known2 + ["out"])}, {F[ni][1].p}_size({names[ni]}))')
        else:
            src = 'out' if kind_ == 'put' else data_writes('out', offs)
            w(f'  {p}_pw{k + 1}({", ".join(["pos"] + vargs + held + known2)}, {F[ni][1].p}_put({src}, {pos_of(ni)}, {names[ni]}))')
    held0 = [f for i2, f in enumerate(names) if i2 != psteps[0][1]]
    if mode == 'group':
        w(f'def {p}_put(out: Array<U32>, +pos: U32, +voff: U32, o: {R}) -> {rtype}:')
    else:
        w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {R}) -> {rtype}:')
    w('  match o:')
    k0, i0 = psteps[0]
    if k0 == 'size':
        w(f'    case {pat}: {p}_pw0({", ".join(["pos"] + vargs + held0 + ["out"])}, {F[i0][1].p}_size({names[i0]}))')
    else:
        w(f'    case {pat}: {p}_pw0({", ".join(["pos"] + vargs + held0)}, {F[i0][1].p}_put({data_writes("out", offs)}, {pos_of(i0)}, {names[i0]}))')


def emit_fields_access(w, p, R, F):
    """Read and replace each field. A Data field is copied out; a field with
    its own storage is swapped out (the affine idiom: the caller gets the old
    value and the object keeps a valid one). Scalars whose SSZ domain is
    narrower than the representation are range-checked on write."""
    names = [f for f, _ in F]
    pat = f'{R}{{' + ', '.join(f'{plus(fs)}{f}' for f, fs in F) + '}'
    for i, (f, fs) in enumerate(F):
        rebuilt = ', '.join(names[:i] + ['v'] + names[i + 1:])
        if fs.data:
            w(f'def {p}_get_{f}(o: {R}) -> {R} & {fs.rep}:')
            w('  match o:')
            w(f'    case {pat}: ({R}{{' + ', '.join(names) + f'}}, {f})')
        else:
            w(f'def {p}_swap_{f}(o: {R}, v: {fs.rep}) -> {R} & {fs.rep}:')
            w('  match o:')
            w(f'    case {pat}: ({R}{{{rebuilt}}}, {f})')
        dom = scalar_ok(fs, 'v')
        if dom is None:
            w(f'def {p}_set_{f}(o: {R}, {plus(fs)}v: {fs.rep}) -> {R}:')
            w('  match o:')
            w(f'    case {pat}: {R}{{{rebuilt}}}')
        else:
            w(f'def {p}_put_{f}(ok: Bool, o: {R}, +v: {fs.rep}) -> {R} & Bool:')
            w('  match ok:')
            w(f'    case True{{}}: ({p}_set_{f}_go(o, v), True{{}})')
            w('    case False{}: (o, False{})')
            w(f'def {p}_set_{f}_go(o: {R}, +v: {fs.rep}) -> {R}:')
            w('  match o:')
            w(f'    case {pat}: {R}{{{rebuilt}}}')
            w(f'def {p}_set_{f}(o: {R}, +v: {fs.rep}) -> {R} & Bool: {p}_put_{f}({dom}, o, v)')


def emit_wide_access(w, p, R, groups):
    """A wide container delegates each field to the group that holds it."""
    gn = [f'g{g.k}' for g in groups]
    pat = f'{R}{{' + ', '.join(f'{plus(g)}{x}' for x, g in zip(gn, groups)) + '}'
    for g in groups:
        others = [x for x in gn if x != f'g{g.k}']
        for f, fs in g.fields:
            rebuilt = ', '.join(gn)
            if fs.data:
                w(f'def {p}_get_{f}(o: {R}) -> {R} & {fs.rep}:')
                w('  match o:')
                w(f'    case {pat}: {p}_got_{f}(' + ', '.join(others) + f', {g.p}_get_{f}(g{g.k}))')
                w(f'def {p}_got_{f}(' + ', '.join(f'{plus(g2)}{x}: {g2.rep}' for x, g2 in zip(gn, groups) if x != f'g{g.k}') +
                  f', pair: {g.rep} & {fs.rep}) -> {R} & {fs.rep}:')
                w(f'  (g{g.k}, {plus(fs)}v) = pair')
                w(f'  ({R}{{{rebuilt}}}, v)')
            else:
                w(f'def {p}_swap_{f}(o: {R}, v: {fs.rep}) -> {R} & {fs.rep}:')
                w('  match o:')
                w(f'    case {pat}: {p}_swapped_{f}(' + ', '.join(others) + f', {g.p}_swap_{f}(g{g.k}, v))')
                w(f'def {p}_swapped_{f}(' + ', '.join(f'{plus(g2)}{x}: {g2.rep}' for x, g2 in zip(gn, groups) if x != f'g{g.k}') +
                  f', pair: {g.rep} & {fs.rep}) -> {R} & {fs.rep}:')
                w(f'  (g{g.k}, v) = pair')
                w(f'  ({R}{{{rebuilt}}}, v)')
            dom = scalar_ok(fs, 'v')
            if dom is None:
                w(f'def {p}_set_{f}(o: {R}, {plus(fs)}v: {fs.rep}) -> {R}:')
                w('  match o:')
                w(f'    case {pat}: {R}{{' + ', '.join((f'{g.p}_set_{f}(g{g.k}, v)' if x == f'g{g.k}' else x) for x in gn) + '}')
            else:
                w(f'def {p}_setr_{f}(' + ', '.join(f'{plus(g2)}{x}: {g2.rep}' for x, g2 in zip(gn, groups) if x != f'g{g.k}') +
                  f', pair: {g.rep} & Bool) -> {R} & Bool:')
                w(f'  (g{g.k}, ok) = pair')
                w(f'  ({R}{{{rebuilt}}}, ok)')
                w(f'def {p}_set_{f}(o: {R}, +v: {fs.rep}) -> {R} & Bool:')
                w('  match o:')
                w(f'    case {pat}: {p}_setr_{f}(' + ', '.join(others) + f', {g.p}_set_{f}(g{g.k}, v))')


def emit_fieldset_root(s, w, p, R, F, mode, data):
    """Root of a plain container (depth ceil(log2 n)) or of a group (a depth-3
    subtree of its container, zero padded): a pure tree of the field roots."""
    names = [f for f, _ in F]
    n = len(F)
    depth = 3 if mode == 'group' else log2ceil(n)
    width = 1 << depth
    # zero subtrees needed above level 0 when padding up to `width` leaves
    zlevels = []
    cnt = n
    for lv in range(depth):
        if cnt % 2 == 1 and lv >= 1:
            zlevels.append(lv)
        if cnt % 2 == 1 and cnt < (width >> lv) and lv >= 1 and lv not in zlevels:
            zlevels.append(lv)
        cnt = (cnt + 1) // 2
    # a level above whose nodes are all padding needs Z(lv) too
    level_nodes = [n]
    for lv in range(depth):
        level_nodes.append((level_nodes[-1] + 1) // 2)
    zlevels = sorted(set(lv for lv in range(1, depth) if level_nodes[lv] % 2 == 1 or level_nodes[lv] < (width >> lv) and level_nodes[lv] % 2 == 1))
    steps = [('f', i) for i in range(n)] + [('z', lv) for lv in zlevels]
    rtype = 'B.Buf & D.Digest' if data else f'B.Buf & ({R} & D.Digest)'

    def bname(st):
        return f'd_{names[st[1]]}' if st[0] == 'f' else f'z{st[1]}'

    def call(st, hexpr='h'):
        if st[0] == 'z':
            return f'O.zero({hexpr}, {st[1]})'
        fs = F[st[1]][1]
        return f'{fs.p}_root({hexpr}, {names[st[1]]}, seg)'

    def combine():
        level = [f'd_{f}' for f in names]
        lv = 0
        while (1 << lv) < width:
            if len(level) % 2:
                level.append('D.zero()' if lv == 0 else f'z{lv}')
            level = [f'D.hash_pair({level[i]}, {level[i + 1]})' for i in range(0, len(level), 2)]
            lv += 1
        return level[0]

    for k in range(len(steps) - 1, -1, -1):
        st = steps[k]
        params = []
        for i2, (f, fs) in enumerate(F):
            if st[0] == 'f' and i2 == st[1] and not fs.data:
                continue
            params.append(f'{plus(fs)}{f}: {fs.rep}')
        params += [f'{bname(x)}: D.Digest' for x in steps[:k]]
        if st[0] == 'f' and not F[st[1]][1].data:
            w(f'def {p}_rt{k}(+seg: U32, {", ".join(params)}, pair: B.Buf & ({F[st[1]][1].rep} & D.Digest)) -> {rtype}:')
            w('  (h, r) = pair')
            w(f'  ({names[st[1]]}, {bname(st)}) = r')
        else:
            w(f'def {p}_rt{k}(+seg: U32, {", ".join(params)}, pair: B.Buf & D.Digest) -> {rtype}:')
            w(f'  (h, {bname(st)}) = pair')
        if k == len(steps) - 1:
            if data:
                w(f'  (h, {combine()})')
            else:
                w(f'  (h, ({R}{{' + ', '.join(names) + f'}}, {combine()}))')
            continue
        nst = steps[k + 1]
        held = [f for i2, (f, fs) in enumerate(F) if not (nst[0] == 'f' and i2 == nst[1] and not fs.data)]
        done = [bname(x) for x in steps[:k + 1]]
        w(f'  {p}_rt{k + 1}(seg, {", ".join(held + done)}, {call(nst)})')
    pat = f'{R}{{' + ', '.join(f'{plus(fs)}{f}' for f, fs in F) + '}'
    held0 = [f for i2, (f, fs) in enumerate(F) if not (i2 == 0 and not fs.data)]
    w(f'def {p}_root(h: B.Buf, o: {R}, +seg: U32) -> {rtype}:')
    w('  match o:')
    w(f'    case {pat}: {p}_rt0(seg, {", ".join(held0)}{", " if held0 else ""}{call(steps[0])})')


def emit_group_force(g, w):
    emit_force_fields(w, g.p, g.rep, g.fields, g.data)


def emit_wide(s, w, groups, hoff, fixed_part):
    """A wide container: a record of its groups."""
    p, R = s.p, s.t.name
    gn = [f'g{g.k}' for g in groups]
    data = s.data
    kind = 'Data' if data else 'Type'
    w(f'type {R} is {kind}:')
    w(f'  {R}{{' + ', '.join(f'{x}: {g.rep}' for x, g in zip(gn, groups)) + '}')
    w(f'def {p}_default() -> {R}: {R}{{' + ', '.join(f'{g.p}_default()' for g in groups) + '}')
    # first variable field of each group: its offset bounds the previous group
    firstvar = {}
    for g in groups:
        for (f, fs), h in zip(g.fields, g.hoff):
            if not fs.fixed:
                firstvar[g.k] = h
                break
    vg = [g.k for g in groups if g.k in firstvar]

    def vend(k):
        later = [x for x in vg if x > k]
        return f'v{later[0]}' if later else 'len'

    steps = [('v', k) for k in vg] + [('g', g.k) for g in groups]

    def btype(st):
        return 'U32' if st[0] == 'v' else groups[st[1]].rep

    def bname(st):
        return f'v{st[1]}' if st[0] == 'v' else f'g{st[1]}'

    def bplus(st):
        return '+' if st[0] == 'v' or groups[st[1]].data else ''

    def call(st):
        if st[0] == 'v':
            return f'B.read32(buf, (off + {firstvar[st[1]]} : U32))'
        return f'{groups[st[1]].p}_read(buf, off, len, {vend(st[1])})'

    for k in range(len(steps) - 1, -1, -1):
        st = steps[k]
        params = ''.join(f'{bplus(x)}{bname(x)}: {btype(x)}, ' for x in steps[:k])
        w(f'def {p}_rd{k}(+off: U32, +len: U32, {params}pair: B.Buf & {btype(st)}) -> B.Buf & {R}:')
        w(f'  (buf, {bplus(st)}{bname(st)}) = pair')
        if k == len(steps) - 1:
            w(f'  (buf, {R}{{' + ', '.join(gn) + '})')
        else:
            args = ', '.join(bname(x) for x in steps[:k + 1])
            w(f'  {p}_rd{k + 1}(off, len, {args}, {call(steps[k + 1])})')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & {R}: {p}_rd0(off, len, {call(steps[0])})')
    pat = f'{R}{{' + ', '.join(f'{plus(g)}{x}' for x, g in zip(gn, groups)) + '}'
    lin = [g for g in groups if not g.data]
    # size
    if lin:
        for j in range(len(lin) - 1, -1, -1):
            g = lin[j]
            others = [f'{plus(g2)}g{g2.k}: {g2.rep}' for g2 in groups if g2.k != g.k and (g2.data or lin.index(g2) > j)]
            done = [f'g{lin[q].k}: {lin[q].rep}' for q in range(j)]
            w(f'def {p}_sz{j}({", ".join(others + done + ["+acc: U32"])}, pair: {g.rep} & U32) -> {R} & U32:')
            w(f'  (g{g.k}, +m) = pair')
            if j == len(lin) - 1:
                w(f'  ({R}{{' + ', '.join(gn) + '}, (acc + m : U32))')
            else:
                nx = lin[j + 1]
                others2 = [f'g{g2.k}' for g2 in groups if g2.k != nx.k and (g2.data or lin.index(g2) > j + 1)]
                done2 = [f'g{lin[q].k}' for q in range(j + 1)]
                w(f'  {p}_sz{j + 1}({", ".join(others2 + done2)}, (acc + m : U32), {nx.p}_size(g{nx.k}))')
        others0 = [x for x, g in zip(gn, groups) if g.k != lin[0].k]
        w(f'def {p}_size(o: {R}) -> {R} & U32:')
        w('  match o:')
        w(f'    case {pat}: {p}_sz0({", ".join(others0)}, {fixed_part}, {lin[0].p}_size(g{lin[0].k}))')
    else:
        w(f'def {p}_size(o: {R}) -> {R} & U32: (o, {fixed_part})')
    # put: groups in order; Data groups are pure writes, linear ones return
    # (out, (group, voff))
    rtype = f'Array<U32> & {R}'
    for j in range(len(lin) - 1, -1, -1):
        g = lin[j]
        params = ['+pos: U32'] + [f'{plus(g2)}g{g2.k}: {g2.rep}' for g2 in groups if g2.k != g.k]
        w(f'def {p}_pw{j}({", ".join(params)}, pair: Array<U32> & ({g.rep} & U32)) -> {rtype}:')
        w('  (out, r) = pair')
        w(f'  (g{g.k}, voff) = r')
        # data groups between this linear group and the next are written here
        nxt = lin[j + 1] if j + 1 < len(lin) else None
        expr = 'out'
        for g2 in groups:
            if g2.data and g2.k > g.k and (nxt is None or g2.k < nxt.k):
                expr = f'{g2.p}_put({expr}, pos, voff, g{g2.k})'
        if nxt is None:
            w(f'  ({expr}, {R}{{' + ', '.join(gn) + '})')
        else:
            held = [f'g{g2.k}' for g2 in groups if g2.k != nxt.k]
            w(f'  {p}_pw{j + 1}(pos, {", ".join(held)}, {nxt.p}_put({expr}, pos, voff, g{nxt.k}))')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {R}) -> {rtype}:')
    w('  match o:')
    if lin:
        expr = 'out'
        for g2 in groups:
            if g2.data and g2.k < lin[0].k:
                expr = f'{g2.p}_put({expr}, pos, {fixed_part}, g{g2.k})'
        held = [f'g{g2.k}' for g2 in groups if g2.k != lin[0].k]
        w(f'    case {pat}: {p}_pw0(pos, {", ".join(held)}, {lin[0].p}_put({expr}, pos, {fixed_part}, g{lin[0].k}))')
    else:
        expr = 'out'
        for g2 in groups:
            expr = f'{g2.p}_put({expr}, pos, {fixed_part}, g{g2.k})'
        w(f'    case {pat}: ({expr}, {R}{{' + ', '.join(gn) + '})')
    # root: the group subtrees are the level-3 nodes; above them a tree of
    # depth ceil(log2(fields)) - 3 padded with Z(3 + level)
    n = len(s.fields)
    depth = log2ceil(n) - 3
    width = 1 << depth
    counts = [len(groups)]
    for lv in range(depth):
        counts.append((counts[-1] + 1) // 2)
    zl = [lv for lv in range(depth) if counts[lv] % 2 == 1]
    steps = [('g', g.k) for g in groups] + [('z', 3 + lv) for lv in zl]

    def rb(st):
        return f'r{st[1]}' if st[0] == 'g' else f'z{st[1]}'

    def rcall(st):
        if st[0] == 'z':
            return f'O.zero(h, {st[1]})'
        return f'{groups[st[1]].p}_root(h, g{st[1]}, seg)'

    def combine():
        level = [f'r{g.k}' for g in groups]
        lv = 0
        while (1 << lv) < width:
            if len(level) % 2:
                level.append(f'z{3 + lv}')
            level = [f'D.hash_pair({level[i]}, {level[i + 1]})' for i in range(0, len(level), 2)]
            lv += 1
        return level[0]

    rt = 'B.Buf & D.Digest' if data else f'B.Buf & ({R} & D.Digest)'
    for k in range(len(steps) - 1, -1, -1):
        st = steps[k]
        params = [f'{plus(g)}g{g.k}: {g.rep}' for g in groups if not (st[0] == 'g' and g.k == st[1] and not g.data)]
        params += [f'{rb(x)}: D.Digest' for x in steps[:k]]
        if st[0] == 'g' and not groups[st[1]].data:
            w(f'def {p}_rt{k}(+seg: U32, {", ".join(params)}, pair: B.Buf & ({groups[st[1]].rep} & D.Digest)) -> {rt}:')
            w('  (h, r) = pair')
            w(f'  (g{st[1]}, {rb(st)}) = r')
        else:
            w(f'def {p}_rt{k}(+seg: U32, {", ".join(params)}, pair: B.Buf & D.Digest) -> {rt}:')
            w(f'  (h, {rb(st)}) = pair')
        if k == len(steps) - 1:
            w(f'  (h, {combine()})' if data else f'  (h, ({R}{{' + ', '.join(gn) + f'}}, {combine()}))')
            continue
        nst = steps[k + 1]
        held = [f'g{g.k}' for g in groups if not (nst[0] == 'g' and g.k == nst[1] and not g.data)]
        done = [rb(x) for x in steps[:k + 1]]
        w(f'  {p}_rt{k + 1}(seg, {", ".join(held + done)}, {rcall(nst)})')
    held0 = [f'g{g.k}' for g in groups if not (g.k == 0 and not g.data)]
    w(f'def {p}_root(h: B.Buf, o: {R}, +seg: U32) -> {rt}:')
    w('  match o:')
    w(f'    case {pat}: {p}_rt0(seg, {", ".join(held0)}, {rcall(steps[0])})')


# ---------------------------------------------------------------------------
# Public per-name API.

def cap_depth(nbytes):
    """The depth O.out_new would compute for this many bytes: the smallest d
    with 2^d words covering (nbytes + 4) bytes, exactly B.capacity's value."""
    words = (nbytes + 4 + 3) // 4
    d = 0
    while (1 << d) < max(1, words):
        d += 1
    return d


def emit_api(g, name, s, w):
    R = s.rep
    p = s.p
    fixed = s.fixed
    w(f'# ---- {name} ----')
    # decode: the generated validator decides the window, then the reader builds
    w(f'def {name}_built(+size: U32, pair: B.Buf & Bool) -> B.Buf & Maybe<&1, {R}>:')
    w('  (buf, ok) = pair')
    w('  match ok:')
    w(f'    case True{{}}: {name}_some({p}_read(buf, 0, size))')
    w('    case False{}: (buf, None{})')
    w(f'def {name}_some(pair: B.Buf & {R}) -> B.Buf & Maybe<&1, {R}>:')
    w(f'  (buf, {"+" if s.data else ""}v) = pair')
    w('  (buf, Some{v})')
    # reorder: some before built
    w(f'def {name}_decode(buf: B.Buf, +size: U32) -> B.Buf & Maybe<&1, {R}>:')
    w(f'  {name}_built(size, {p}_ok(buf, 0, size))')
    w(f'def {name}_build(buf: B.Buf, +size: U32) -> B.Buf & {R}: {p}_read(buf, 0, size)')
    # encode
    if s.data:
        # the output of a fixed-size value has a size known here, so the
        # allocation takes the depth directly instead of computing it
        w(f'def {name}_encode(+o: {R}) -> B.Buf: '
          f'O.out_done({s.fsize}, {p}_put(O.out_at({cap_depth(s.fsize)}n), 0, o))')
        w(f'def {name}_hash_tree_root(h: B.Buf, +o: {R}) -> B.Buf & D.Digest: {p}_root(h, o, 0)')
    else:
        w(f'def {name}_enc_out(+n: U32, pair: Array<U32> & {R}) -> {R} & B.Buf:')
        w('  (out, o) = pair')
        w('  (o, O.out_done(n, out))')
        w(f'def {name}_enc_sized(pair: {R} & U32) -> {R} & B.Buf:')
        w('  (o, +n) = pair')
        w(f'  {name}_enc_out(n, {p}_put(O.out_new(n), 0, o))')
        w(f'def {name}_encode(o: {R}) -> {R} & B.Buf: {name}_enc_sized({p}_size(o))')
        w(f'def {name}_hash_tree_root(h: B.Buf, o: {R}) -> B.Buf & ({R} & D.Digest): {p}_root(h, o, 0)')
    w('')


def reorder(text):
    """Bend has no forward references: order each group so that callees come first."""
    import re
    blocks = re.split(r'\n(?=def |type |# ---- )', text)
    head, rest = blocks[0], blocks[1:]
    defs = {}
    order = []
    for b in rest:
        m = re.match(r'(def|type) ([A-Za-z0-9_]+)', b)
        nm = m.group(2) if m else None
        order.append((nm, b))
        if nm:
            defs[nm] = b
    placed, out = set(), []

    def place(nm, b, stack):
        if nm in placed or nm in stack:
            return
        stack = stack | {nm}
        body = b.split('\n', 1)[1] if '\n' in b else ''
        sig = b.split('\n', 1)[0]
        for ref in set(re.findall(r'\b([A-Za-z][A-Za-z0-9_]*)\(', body + sig)) | set(re.findall(r'\b([A-Z][A-Za-z0-9_]*)\{', body + sig)):
            if ref in defs and ref != nm:
                place(ref, defs[ref], stack)
        placed.add(nm)
        out.append(b)

    for nm, b in order:
        if nm is None:
            out.append(b)
        else:
            place(nm, b, set())
    return head + '\n' + '\n'.join(x.rstrip('\n') + '\n' for x in out)


GROUP_TYPES = 12
FUZZ_GROUP = 4            # names per mutation-driver program          # named types per generated program; one program's compile
                          # stays near 3 GB, while all 109 in one exceeds the 6.5 GB cap


# ---------------------------------------------------------------------------
# Values from a seed, and the mutation entry point the fuzz campaign drives.
# A seed is one word; the value it stands for is fixed by the rule below and
# mirrored exactly in tests_generated/fuzz_objects.py, so the campaign can
# apply the same operation on both sides and compare full bytes and roots.
#
#   bool           the low bit of the seed
#   uint8/16/32    the seed, masked to the width
#   uint64         word 0 = seed, word 1 = seed + 1
#   byte/bit rec   word j = seed + j, with the padding bits of a bit vector
#                  and the bytes past the length of a byte vector cleared
#   container      field i gets the seed + 1 + i
#
# A shape a seed cannot build (a collection inside a container, a boxed field)
# is simply not offered as an operation; types/obj_fuzz_ops.json lists exactly
# the operations that exist, per name, and the mirror reads that file.

def seedable(s):
    """Shapes a seed can build: scalars, word records, and Data containers of
    those. Collections are excluded: they are mutated element by element."""
    k = s.kind
    if k in ('bool', 'u8', 'u16', 'u32', 'u64', 'rec', 'uwide'):
        return True
    if k == 'container' and s.data and len(s.fields) <= GROUP:
        return all(seedable(fs) for _, fs in s.fields)
    return False


def rec_mask(s, j):
    """The mask of word j of a byte or bit vector record: a byte vector past
    its length and the padding bits of a bit vector must read as zero."""
    t = s.t
    if t.kind == 'bits':
        bits = t.size - 32 * j
        return (1 << bits) - 1 if 0 < bits < 32 else 0xFFFFFFFF
    nb = (t.size if t.kind == 'bytes' else t.size) - 4 * j
    return (1 << (8 * nb)) - 1 if 0 < nb < 4 else 0xFFFFFFFF


def emit_seed(s, w):
    """A value of this shape built from one seed word."""
    p, k = s.p, s.kind
    if k == 'bool':
        w(f'def {p}_seed(+x: U32) -> Bool: U32.is_eq((x .&. 1 : U32), 1)')
    elif k == 'u8':
        w(f'def {p}_seed(+x: U32) -> U32: (x .&. 255 : U32)')
    elif k == 'u16':
        w(f'def {p}_seed(+x: U32) -> U32: (x .&. 65535 : U32)')
    elif k == 'u32':
        w(f'def {p}_seed(+x: U32) -> U32: x')
    elif k == 'u64':
        w(f'def {p}_seed(+x: U32) -> O.U64: O.U64{{x, (x + 1 : U32)}}')
    elif k in ('rec', 'uwide'):
        ws = []
        for j in range(s.nw):
            m = rec_mask(s, j) if k == 'rec' else 0xFFFFFFFF
            term = f'(x + {j} : U32)'
            if m != 0xFFFFFFFF:
                term = f'({term} .&. {m} : U32)'
            ws.append(term)
        w(f'def {p}_seed(+x: U32) -> {s.rep}: {s.rep}{{' + ', '.join(ws) + '}')
    elif k == 'container':
        args = ', '.join(f'{fs.p}_seed((x + {i + 1} : U32))' for i, (_, fs) in enumerate(s.fields))
        w(f'def {p}_seed(+x: U32) -> {s.t.name}: {s.t.name}{{{args}}}')


def coll_ops(fs):
    """The operations a collection shape offers: writing an element, and for a
    list appending one. Returns [] when the elements cannot be built."""
    k = fs.kind
    if k == 'fixwords':
        return ['set'] if fs.t.kind == 'bytes' else []
    if k == 'bitlist':
        return ['set', 'append']
    if k == 'bytelist':
        return ['set', 'append']
    if k in ('packed', 'packed_elems'):
        el = fs.g.shape(fs.t.elem)
        if not seedable(el):
            return []
        return ['set', 'append'] if fs.t.kind == 'list' else ['set']
    if k == 'seq':
        if not seedable(fs.elem):
            return []
        return ['set', 'append'] if fs.t.kind == 'list' else ['set']
    return []


def coll_elem_seed(fs):
    """The term that builds one element of this collection from a seed."""
    k = fs.kind
    if k == 'fixwords':
        return '(b .&. 255 : U32)'
    if k == 'bitlist':
        return 'U32.is_eq((b .&. 1 : U32), 1)'
    if k == 'bytelist':
        return '(b .&. 255 : U32)'
    if k in ('packed', 'packed_elems'):
        return f'{fs.g.shape(fs.t.elem).p}_seed(b)'
    return f'{fs.elem.p}_seed(b)'


FUZZ_SLOTS_MAX = 8        # operations offered per name
FUZZ_SLOTS_WIDE = 2       # ... and per wide container, whose every write
                          # rebuilds a record of groups: more than a couple of
                          # those in one program builds a C function large
                          # enough to crash the platform compiler's register
                          # allocator at the -O2 the pinned toolchain uses


def fuzz_slots(g, name, s):
    """The mutation operations offered for one name, in a fixed order.

    Collection operations come first (they carry the bounds and the append
    limit), then field writes spread over the field list. At most
    FUZZ_SLOTS_MAX operations per name: a wide container's write rebuilds its
    whole record, and dozens of those in one program crash the platform C
    compiler. types/obj_fuzz_ops.json records exactly what each name offers,
    and the fuzz campaign drives only those."""
    out = []
    if s.kind == 'container':
        fields = s.fields
        for f, fs in fields:
            if fs.data and seedable(fs) and scalar_ok(fs, 'v') is None:
                out.append({'kind': 'set_field', 'field': f, 'checked': False})
            elif fs.data and seedable(fs):
                out.append({'kind': 'set_field', 'field': f, 'checked': True})
            else:
                for op in coll_ops(fs):
                    out.append({'kind': op + '_elem' if op == 'set' else 'append', 'field': f})
    else:
        for op in coll_ops(s):
            out.append({'kind': op + '_elem' if op == 'set' else 'append', 'field': None})
    cap = FUZZ_SLOTS_WIDE if (s.kind == 'container' and len(s.fields) > GROUP) else FUZZ_SLOTS_MAX
    if len(out) <= cap:
        return out
    colls = [o for o in out if o['kind'] != 'set_field']
    fields = [o for o in out if o['kind'] == 'set_field']
    colls = colls[:cap]
    room = max(0, cap - len(colls))
    if room and fields:
        step = max(1, len(fields) // room)
        fields = [fields[i] for i in range(0, len(fields), step)][:room]
    else:
        fields = []
    return (colls + fields)[:cap]


def emit_fuzz(g, name, s, w):
    """<Name>_fuzz(o, sel, a, b): apply operation `sel` of this name's table,
    with `a` the index it addresses and `b` the seed of the value it writes.
    Returns the object and whether the operation was accepted; a rejected one
    leaves the object as it was, which is the collection API's own behaviour."""
    slots = fuzz_slots(g, name, s)
    R = qual_local(s.rep)
    for k, slot in enumerate(slots):
        f = slot['field']
        fs = dict(s.fields)[f] if f is not None else s
        if slot['kind'] == 'set_field':
            if slot['checked']:
                w(f'def {name}_fz{k}(o: {R}, +a: U32, +b: U32) -> {R} & Bool:')
                w(f'  {name}_set_{f}(o, {fs.p}_seed(b))')
            else:
                w(f'def {name}_fz{k}(o: {R}, +a: U32, +b: U32) -> {R} & Bool:')
                w(f'  ({name}_set_{f}(o, {fs.p}_seed(b)), True{{}})')
            continue
        CR = fs.rep
        call = f'{fs.p}_set(c, a, {coll_elem_seed(fs)})' if slot['kind'] == 'set_elem' \
            else f'{fs.p}_append(c, {coll_elem_seed(fs)})'
        if f is None:
            w(f'def {name}_fz{k}(o: {CR}, +a: U32, +b: U32) -> {CR} & Bool:')
            w(f'  {fs.p}_' + ('set' if slot['kind'] == 'set_elem' else 'append')
              + ('(o, a, ' if slot['kind'] == 'set_elem' else '(o, ')
              + coll_elem_seed(fs).replace('b', 'b') + ')')
            continue
        w(f'def {name}_fz{k}_fin(ok: Bool, pr: {R} & {CR}) -> {R} & Bool:')
        w('  (obj, old) = pr')
        w('  (obj, ok)')
        w(f'def {name}_fz{k}_back(obj: {R}, res: {CR} & Bool) -> {R} & Bool:')
        w('  (c, ok) = res')
        w(f'  {name}_fz{k}_fin(ok, {name}_swap_{f}(obj, c))')
        w(f'def {name}_fz{k}_in(+a: U32, +b: U32, pr: {R} & {CR}) -> {R} & Bool:')
        w('  (obj, c) = pr')
        w(f'  {name}_fz{k}_back(obj, {call})')
        w(f'def {name}_fz{k}(o: {R}, +a: U32, +b: U32) -> {R} & Bool:')
        w(f'  {name}_fz{k}_in(a, b, {name}_swap_{f}(o, {fs.p}_default()))')
    if not slots:
        w(f'def {name}_fuzz(o: {R}, +sel: U32, +a: U32, +b: U32) -> {R} & Bool:')
        w('  (o, False{})')
        return slots
    # A wide type has dozens of operations; one match over all of them makes a
    # function large enough to crash the platform C compiler's register
    # allocator, so the dispatch is two levels of eight.
    chunks = [list(range(i, min(i + 8, len(slots)))) for i in range(0, len(slots), 8)]
    for j, chunk in enumerate(chunks):
        w(f'def {name}_fzc{j}(o: {R}, +sel: U32, +a: U32, +b: U32) -> {R} & Bool:')
        w('  match sel:')
        for k in chunk[:-1]:
            w(f'    case {k}: {name}_fz{k}(o, a, b)')
        w(f'    case _: {name}_fz{chunk[-1]}(o, a, b)')
    w(f'def {name}_fuzz_hi(+c: U32, o: {R}, +sel: U32, +a: U32, +b: U32) -> {R} & Bool:')
    w('  match c:')
    for j in range(len(chunks) - 1):
        w(f'    case {j}: {name}_fzc{j}(o, sel, a, b)')
    w(f'    case _: {name}_fzc{len(chunks) - 1}(o, sel, a, b)')
    w(f'def {name}_fuzz(o: {R}, +sel: U32, +a: U32, +b: U32) -> {R} & Bool:')
    w(f'  {name}_fuzz_hi(U32.shrn(sel, 3n), o, sel, a, b)')
    return slots


def qual_local(rep):
    return rep


def emit_group(g, names, ns, k, with_fuzz=False, prefix='g'):
    """types/fulu_obj_g{k}.bend: a sum over this group's objects and the
    operations dispatched by the name's global index (the frozen schema
    order). The benchmark and check programs use one group each."""
    L = []
    w = L.append
    w('import Base')
    w('import ../src/buffer.bend as B')
    w('import ../src/digest.bend as D')
    w('import ../src/obj.bend as O')
    w('import ./fulu_obj.bend as T')
    w('')
    w(f'# GENERATED by codegen/generate.py. Do not edit. {"Fuzz group" if with_fuzz else "Group"} {k}: '
      + ', '.join(n for n, _ in ns) + '.')
    w('type Any is Type:')
    for n, i in ns:
        w(f'  A_{n}{{v: {qual(g.shape(names[n]).rep)}}}')
    w('')
    for n, i in ns:
        sh = g.shape(names[n])
        R = qual(sh.rep)
        w(f'def wrap_{n}(m: Maybe<&1, {R}>, buf: B.Buf) -> B.Buf & Maybe<&1, Any>:')
        w('  match m:')
        w(f'    case Some{{v}}: (buf, Some{{A_{n}{{v}}}})')
        w('    case None{}: (buf, None{})')
        w(f'def some_{n}(pair: B.Buf & Maybe<&1, {R}>) -> B.Buf & Maybe<&1, Any>:')
        w('  (buf, m) = pair')
        w(f'  wrap_{n}(m, buf)')
    w('# Decode by index: the name\'s generated validator, then its reader.')
    w('def decode(+i: U32, buf: B.Buf, +size: U32) -> B.Buf & Maybe<&1, Any>:')
    w('  match i:')
    for n, i in ns:
        w(f'    case {i}: some_{n}(T.{n}_decode(buf, size))')
    w('    case _: (buf, None{})')
    enc, rt, fo = [], [], []
    for n, i in ns:
        sh = g.shape(names[n])
        R = qual(sh.rep)
        if sh.data:
            w(f'def enc_{n}(+v: {R}) -> Any & B.Buf: (A_{n}{{v}}, T.{n}_encode(v))')
            w(f'def root_{n}(+v: {R}, pair: B.Buf & D.Digest) -> B.Buf & (Any & D.Digest):')
            w('  (h, d) = pair')
            w(f'  (h, (A_{n}{{v}}, d))')
            w(f'def force_{n}(+v: {R}) -> Any & U32: (A_{n}{{v}}, T.{sh.p}_force(v))')
            enc.append(f'    case A_{n}{{+v}}: enc_{n}(v)')
            rt.append(f'    case A_{n}{{+v}}: root_{n}(v, T.{n}_hash_tree_root(h, v))')
            fo.append(f'    case A_{n}{{+v}}: force_{n}(v)')
        else:
            w(f'def enc_{n}(pair: {R} & B.Buf) -> Any & B.Buf:')
            w('  (v, out) = pair')
            w(f'  (A_{n}{{v}}, out)')
            w(f'def root_{n}(pair: B.Buf & ({R} & D.Digest)) -> B.Buf & (Any & D.Digest):')
            w('  (h, r) = pair')
            w('  (v, d) = r')
            w(f'  (h, (A_{n}{{v}}, d))')
            w(f'def force_{n}(pair: {R} & U32) -> Any & U32:')
            w('  (v, +x) = pair')
            w(f'  (A_{n}{{v}}, x)')
            enc.append(f'    case A_{n}{{v}}: enc_{n}(T.{n}_encode(v))')
            rt.append(f'    case A_{n}{{v}}: root_{n}(T.{n}_hash_tree_root(h, v))')
            fo.append(f'    case A_{n}{{v}}: force_{n}(T.{sh.p}_force(v))')
    w('def encode(a: Any) -> Any & B.Buf:')
    w('  match a:')
    L.extend(enc)
    w('def root(h: B.Buf, a: Any) -> B.Buf & (Any & D.Digest):')
    w('  match a:')
    L.extend(rt)
    w('def force(a: Any) -> Any & U32:')
    w('  match a:')
    L.extend(fo)
    # decode + force in one call: the decode benchmark consumes the whole
    # object, so no construction work is left unevaluated
    w('def force_fin(buf: B.Buf, pair: Any & U32) -> B.Buf & (U32 & U32):')
    w('  (a, +x) = pair')
    w('  (buf, (x, 1))')
    w('def force_m(m: Maybe<&1, Any>, buf: B.Buf) -> B.Buf & (U32 & U32):')
    w('  match m:')
    w('    case None{}: (buf, (0, 0))')
    w('    case Some{a}: force_fin(buf, force(a))')
    w('def force_p(pair: B.Buf & Maybe<&1, Any>) -> B.Buf & (U32 & U32):')
    w('  (buf, m) = pair')
    w('  force_m(m, buf)')
    w('def decode_force(+i: U32, buf: B.Buf, +size: U32) -> B.Buf & (U32 & U32):')
    w('  force_p(decode(i, buf, size))')
    # one mutation of the decoded object, selected by the name's operation
    # table (types/obj_fuzz_ops.json); the fuzz campaign drives this
    if not with_fuzz:
        return '\n'.join(L) + '\n'
    fz = []
    for n, i in ns:
        sh = g.shape(names[n])
        R = qual(sh.rep)
        w(f'def fuzz_{n}_fin(pr: {R} & Bool) -> Any & Bool:')
        w(f'  ({"+" if sh.data else ""}v, ok) = pr')
        w(f'  (A_{n}{{v}}, ok)')
        if sh.data:
            w(f'def fuzz_{n}(+sel: U32, +a: U32, +b: U32, +v: {R}) -> Any & Bool:')
            w(f'  fuzz_{n}_fin(T.{n}_fuzz(v, sel, a, b))')
            fz.append(f'    case A_{n}{{+v}}: fuzz_{n}(sel, a, b, v)')
        else:
            w(f'def fuzz_{n}(+sel: U32, +a: U32, +b: U32, v: {R}) -> Any & Bool:')
            w(f'  fuzz_{n}_fin(T.{n}_fuzz(v, sel, a, b))')
            fz.append(f'    case A_{n}{{v}}: fuzz_{n}(sel, a, b, v)')
    w('def fuzz(a0: Any, +sel: U32, +a: U32, +b: U32) -> Any & Bool:')
    w('  match a0:')
    L.extend(fz)
    return '\n'.join(L) + '\n'


PROGRAM = r"""import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj_g@K@.bend as G
import ../compact/objio.bend as IOx

# GENERATED by codegen/generate.py. Do not edit.
# The typed object API of group @K@ under measurement. SSZ_MODE selects the
# operation: 0 checks one input (decode, encode to SSZ_OUTPUT, root), 1 times
# SSZ_OPS decodes (each builds and consumes a whole object), 2 times SSZ_OPS
# encodes of one decoded object, 3 times SSZ_OPS roots of it. Reading the
# input, writing the output and the one decode that mode 2 and 3 need are all
# outside the timed region, as the Go reference does.

def word_of(pair: B.Buf & U32) -> U32:
  (b, +w) = pair
  w

def sized_word(pair: B.Buf & U32) -> U32:
  (b, +n) = pair
  word_of(B.word(b, U32.shrn(n, 2n)))

# Consumes an encoding by reading its last word.
def consume(out: B.Buf) -> U32: sized_word(B.size(out))

def dloop(+k: Nat, +i: U32, +size: U32, +acc: U32, +good: U32, pair: B.Buf & (U32 & U32)) -> B.Buf & (U32 & U32):
  match k:
    case 0n:
      (buf, r) = pair
      (x, g) = r
      (buf, ((acc .^. x : U32), (good + g : U32)))
    case 1n+p:
      (buf, r) = pair
      (x, g) = r
      dloop(p, i, size, (acc .^. x : U32), (good + g : U32), G.decode_force(i, buf, size))

def dec_ok(all: Bool, +ms: Nat, +acc: U32, +good: U32) -> IO(Unit):
  match all:
    case True{}: IO.print("MS=" ++ Nat.show(ms) ++ " ACC=" ++ U32.show(acc) ++ " ACCEPTED=" ++ U32.show(good))
    case False{}: IO.die(Unit, 1, "decode rejected")

def dec_time(+ops: U32, +t0: Nat, +acc: U32, +good: U32) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    dec_ok(U32.is_eq(good, ops), Nat.sub(t1, t0), acc, good)

def dec_report(+ops: U32, +t0: Nat, pair: B.Buf & (U32 & U32)) -> IO(Unit):
  (buf, r) = pair
  (acc, good) = r
  dec_time(ops, t0, acc, good)

def run_dec(+i: U32, +ops: U32, +size: U32, buf: B.Buf) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    dec_report(ops, t0, dloop(U32.to_nat((ops - 1 : U32)), i, size, 0, 0, G.decode_force(i, buf, size)))

def eloop(+k: Nat, +acc: U32, pair: G.Any & B.Buf) -> G.Any & (U32 & B.Buf):
  match k:
    case 0n:
      (a, out) = pair
      (a, (acc, out))
    case 1n+p:
      (a, out) = pair
      eloop(p, (acc .^. consume(out) : U32), G.encode(a))

def enc_time(+t0: Nat, +acc: U32, out: B.Buf) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))
    IOx.emit_encoding(B.size(out))

def enc_report(+t0: Nat, pair: G.Any & (U32 & B.Buf)) -> IO(Unit):
  (a, r) = pair
  (acc, out) = r
  enc_time(t0, acc, out)

def run_enc(+ops: U32, a: G.Any) -> IO(Unit):
  do IO<Unit>:
    t0 : Nat <- IO.now()
    enc_report(t0, eloop(U32.to_nat((ops - 1 : U32)), 0, G.encode(a)))

def rlast(+acc: U32, h: B.Buf, a: G.Any, +d: D.Digest) -> B.Buf & (G.Any & (U32 & D.Digest)):
  (h, (a, ((acc .^. IOx.fold(d) : U32), d)))

def rloop(+k: Nat, +acc: U32, pair: B.Buf & (G.Any & D.Digest)) -> B.Buf & (G.Any & (U32 & D.Digest)):
  match k:
    case 0n:
      (h, r) = pair
      (a, d) = r
      rlast(acc, h, a, d)
    case 1n+p:
      (h, r) = pair
      (a, d) = r
      rloop(p, (acc .^. IOx.fold(d) : U32), G.root(h, a))

def root_time(+t0: Nat, +acc: U32, +d: D.Digest) -> IO(Unit):
  do IO<Unit>:
    t1 : Nat <- IO.now()
    IO.print("MS=" ++ Nat.show(Nat.sub(t1, t0)) ++ " ACC=" ++ U32.show(acc))
    IO.print("ROOTSUM=" ++ U32.show(IOx.rootsum(d)))
    IO.print("ROOTWORDS=" ++ IOx.words(d))

def root_report(+t0: Nat, pair: B.Buf & (G.Any & (U32 & D.Digest))) -> IO(Unit):
  (h, r) = pair
  (a, x) = r
  (acc, d) = x
  root_time(t0, acc, d)

def run_root(+ops: U32, a: G.Any) -> IO(Unit):
  do IO<Unit>:
    h : B.Buf <- IO.pure(B.Buf, O.hasher())
    t0 : Nat <- IO.now()
    root_report(t0, rloop(U32.to_nat((ops - 1 : U32)), 0, G.root(h, a)))

def check_show(out: B.Buf, +d: D.Digest) -> IO(Unit):
  do IO<Unit>:
    IO.print("ROOTSUM=" ++ U32.show(IOx.rootsum(d)))
    IO.print("ROOTWORDS=" ++ IOx.words(d))
    IOx.emit_encoding(B.size(out))

def check_root(out: B.Buf, pair: B.Buf & (G.Any & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (a, d) = r
  check_show(out, d)

def check_enc(pair: G.Any & B.Buf) -> IO(Unit):
  (a, out) = pair
  check_root(out, G.root(O.hasher(), a))

def run_check(a: G.Any) -> IO(Unit):
  do IO<Unit>:
    IO.print("DECODED=1")
    check_enc(G.encode(a))

def with_obj(+mode: U32, +ops: U32, a: G.Any) -> IO(Unit):
  match mode:
    case 2: run_enc(ops, a)
    case 3: run_root(ops, a)
    case _: run_check(a)

def on_decoded(m: Maybe<&1, G.Any>, +mode: U32, +ops: U32) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{a}: with_obj(mode, ops, a)

def decoded(+mode: U32, +ops: U32, pair: B.Buf & Maybe<&1, G.Any>) -> IO(Unit):
  (buf, m) = pair
  on_decoded(m, mode, ops)

def dispatch(+mode: U32, +i: U32, +ops: U32, +size: U32, buf: B.Buf) -> IO(Unit):
  match mode:
    case 1: run_dec(i, ops, size, buf)
    case _: decoded(mode, ops, G.decode(i, buf, size))

def with_input(+mode: U32, +i: U32, +ops: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  dispatch(mode, i, ops, size, buf)

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +index : U32 <- IOx.env_u32("SSZ_INDEX")
    +ops : U32 <- IOx.env_u32("SSZ_OPS")
    input : B.Buf & U32 <- IOx.load()
    with_input(mode, index, ops, input)
"""


PROGRAM_FUZZ = r"""import Base
import ../../src/buffer.bend as B
import ../../src/digest.bend as D
import ../../src/obj.bend as O
import ../../types/fulu_obj_f@K@.bend as G
import ../compact/objio.bend as IOx

# GENERATED by codegen/generate.py. Do not edit.
# The mutation driver of fuzz group @K@, for tests_generated/fuzz_objects.py:
# decode SSZ_INPUT as the name at SSZ_INDEX, apply operation SSZ_SEL of that
# name's table (types/obj_fuzz_ops.json) at index SSZ_IDX with value seed
# SSZ_SEED, then re-encode to SSZ_OUTPUT and print the root of the result.
# SSZ_MODE 0 skips the mutation, which is the plain decode/encode/root check.

def check_show(out: B.Buf, d: D.Digest) -> IO(Unit):
  do IO<Unit>:
    IO.print("ROOTWORDS=" ++ IOx.words(d))
    IOx.emit_encoding(B.size(out))

def check_root(out: B.Buf, pair: B.Buf & (G.Any & D.Digest)) -> IO(Unit):
  (h, r) = pair
  (a, d) = r
  check_show(out, d)

def check_enc(pair: G.Any & B.Buf) -> IO(Unit):
  (a, out) = pair
  check_root(out, G.root(O.hasher(), a))

def status(ok: Bool) -> IO(Unit):
  match ok:
    case True{}: IO.print("STATUS=1")
    case False{}: IO.print("STATUS=0")

def mutated(pr: G.Any & Bool) -> IO(Unit):
  (a, ok) = pr
  do IO<Unit>:
    status(ok)
    check_enc(G.encode(a))

def run_plain(a: G.Any) -> IO(Unit):
  do IO<Unit>:
    IO.print("STATUS=1")
    check_enc(G.encode(a))

def with_obj(+mode: U32, +sel: U32, +idx: U32, +seed: U32, a: G.Any) -> IO(Unit):
  match mode:
    case 0: run_plain(a)
    case _: mutated(G.fuzz(a, sel, idx, seed))

def on_decoded(m: Maybe<&1, G.Any>, +mode: U32, +sel: U32, +idx: U32, +seed: U32) -> IO(Unit):
  match m:
    case None{}: IO.die(Unit, 1, "DECODED=0")
    case Some{a}:
      do IO<Unit>:
        IO.print("DECODED=1")
        with_obj(mode, sel, idx, seed, a)

def decoded(+mode: U32, +sel: U32, +idx: U32, +seed: U32, pair: B.Buf & Maybe<&1, G.Any>) -> IO(Unit):
  (buf, m) = pair
  on_decoded(m, mode, sel, idx, seed)

def with_input(+mode: U32, +i: U32, +sel: U32, +idx: U32, +seed: U32, pair: B.Buf & U32) -> IO(Unit):
  (buf, +size) = pair
  decoded(mode, sel, idx, seed, G.decode(i, buf, size))

def main() -> IO(Unit):
  do IO<Unit>:
    +mode : U32 <- IOx.env_u32("SSZ_MODE")
    +index : U32 <- IOx.env_u32("SSZ_INDEX")
    +sel : U32 <- IOx.env_u32("SSZ_SEL")
    +idx : U32 <- IOx.env_u32("SSZ_IDX")
    +seed : U32 <- IOx.env_u32("SSZ_SEED")
    input : B.Buf & U32 <- IOx.load()
    with_input(mode, index, sel, idx, seed, input)
"""


def qual(rep):
    """A representation type as seen from the index module."""
    if rep in ('Bool', 'U32') or rep.startswith('O.'):
        return rep
    return 'T.' + rep


def main():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = Gen()
    text = reorder(emit_all(g, names))
    outputs = {ROOT / 'types/fulu_obj.bend': text}
    order = list(names)
    groups = [order[i:i + GROUP_TYPES] for i in range(0, len(order), GROUP_TYPES)]
    table = {}
    for k, gn in enumerate(groups):
        ns = [(n, order.index(n)) for n in gn]
        outputs[ROOT / f'types/fulu_obj_g{k}.bend'] = emit_group(g, names, ns, k)
        outputs[ROOT / f'benchmarks/objprog/g{k}.bend'] = PROGRAM.replace('@K@', str(k))
        for n, i in ns:
            table[n] = {'group': k, 'index': i}
    outputs[ROOT / 'types/obj_groups.json'] = json.dumps(table, indent=1) + '\n'
    # The mutation drivers live in their own small programs: the measured
    # programs carry twelve names each and adding the mutation code to them
    # builds C functions the platform compiler cannot register-allocate.
    fgroups = [order[i:i + FUZZ_GROUP] for i in range(0, len(order), FUZZ_GROUP)]
    ftable = {}
    for k, gn in enumerate(fgroups):
        ns = [(n, order.index(n)) for n in gn]
        outputs[ROOT / f'types/fulu_obj_f{k}.bend'] = emit_group(g, names, ns, k, with_fuzz=True, prefix='f')
        outputs[ROOT / f'benchmarks/objprog/f{k}.bend'] = PROGRAM_FUZZ.replace('@K@', str(k))
        for n, i in ns:
            ftable[n] = {'program': k, 'index': i, 'ops': g.fuzz_ops[n]}
    outputs[ROOT / 'types/obj_fuzz_ops.json'] = json.dumps(ftable, indent=1) + '\n'
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in outputs.items() if not p.exists() or p.read_text() != t]
        if stale:
            print('stale generated sources: ' + ', '.join(stale) + ' (run codegen/generate.py)')
            sys.exit(1)
        print('generated sources are current')
        return
    for p, t in outputs.items():
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(t)
    print(f'types/fulu_obj.bend: {len(g.order)} shapes, {len(names)} names, {len(text.splitlines())} lines; '
          f'{len(groups)} groups of up to {GROUP_TYPES} names')


if __name__ == '__main__':
    main()
