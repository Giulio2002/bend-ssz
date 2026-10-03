#!/usr/bin/env python3
"""Generate the typed SSZ object runtime from codegen/fulu.yaml.

    /opt/homebrew/bin/python3 codegen/impl/typed_object_runtime.py [--check]

Generates the typed object runtime: one Bend record per container (one field per
SSZ field) and, for every distinct field shape, the decoder from a validated
window, the encoder into a pre-zeroed output, the size and the root, all
composed from src/obj.bend, plus the public per-name operations (decode,
encode, hash_tree_root) and field access for all 109 names. The runtime is
written split per readable name and operation, types/<Name>_{def,encode_ssz,
decode_ssz,hashtreeroot}_generated.bend (codegen/impl/runtime_file_split.py; the one-file
monoliths types/fulu_obj.bend / generic_obj.bend are computed but not
written), with types/fulu_obj_g<k>.bend / _f<k>.bend, the dispatch the
benchmark programs use.

The generator is not trusted: the output is ordinary Bend checked by the
pinned compiler, its runtime behaviour is checked against the official cases
and fastssz outputs, and its laws are generated separately (codegen/proofs/collections/object_field_access_laws.py).
`--check` regenerates in memory and fails if the files on disk differ.

The YAML is parsed by the host (Python + PyYAML): stock Bend has no YAML or
general text parser. Everything downstream of parsing - representation
choice, layout and every emitted definition - is a deterministic function of
the resolved schema tree printed by this script.
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[2]))  # the repository root: `codegen` is importable when this file runs as a script
import json
import re
import sys

from codegen.core import fulu_schema_loader as schema  # noqa: E402

from codegen.core.repository_paths import ROOT  # noqa: E402
RECORD_MAX = 96           # byte vectors / bit vectors up to this many bytes are word records (Data, inline);
                          # longer ones are packed Words. Measured with boxed linear list elements: 32 is
                          # up to ~15% faster on block encodes but makes Validator (its pubkey) and every
                          # signed message linear, which turns a copying element read into a move and
                          # drops them out of the whole-word codec-law class; 48 makes the pinned
                          # toolchain's clang (Apple clang 17.0.0, -O3) abort on the native memory driver
                          # ("live register clobbered by inserted prologue instructions"). 96 keeps every
                          # block serializer under 4x Go.
FIXED_COPY_MAX_WORDS = 64  # fixed packed runs up to this many words get a straight-line aligned writer
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
    if t.kind in ('container', 'pcontainer', 'cunion'):
        return 'C:' + t.name
    if t.kind in ('vector', 'list'):
        return f'{t.kind}[{key(t.elem)},{t.size}]'
    if t.kind == 'plist':
        return f'plist[{key(t.elem)}]'
    return f'{t.kind}{t.size}'


def ident(t):
    if t.kind in ('container', 'pcontainer', 'cunion'):
        return t.name
    if t.kind in ('vector', 'list'):
        return f'{t.kind[0]}{t.size}_{ident(t.elem)}'
    if t.kind == 'plist':
        return f'pl_{ident(t.elem)}'
    if t.kind == 'pbits':
        return 'pbits'
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
        # The progressive forms are the unlimited analogues of their bounded
        # cousins: the same wire layout and the same validator (the limit check
        # is vacuous), with a progressive chunk tree instead of a fixed-depth
        # one. They are classified as those cousins; `self.prog` selects the
        # progressive merkleization at the few places it differs.
        if k == 'pbits':
            return 'bitlist'
        if k == 'pcontainer':
            return 'container'
        if k == 'cunion':
            return 'cunion'
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
        if k in ('vector', 'list', 'plist'):
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
        # `prog` marks the progressive forms: no limit, progressive chunk tree.
        self.prog = t.kind in ('plist', 'pbits', 'pcontainer')
        if self.kind == 'cunion':
            self.options = [(f, self.g.shape(ft)) for f, ft in t.fields]
            self.data = False
            self.rep = t.name
            return
        if self.kind in ('rec', 'uwide'):
            nbytes = t.size if t.kind != 'bits' else (t.size + 7) // 8
            self.nbytes = nbytes
            self.nw = (nbytes + 3) // 4
            self.rep = {'bytes': f'Bytes{t.size}', 'bits': f'Bitvector{t.size}', 'uint': f'Uint{8 * t.size}'}[t.kind]
            self.g.records[self.rep] = self.nw
        elif self.kind == 'seq':
            # A list's storage holds Data elements inline; an element with
            # storage of its own (packed bytes, nested lists) is held behind a
            # pointer (O.Boxed), so the loops move one word per element and an
            # unused slot is the empty box BNone - no default element is ever
            # built to fill or to swap with. `pelem` is the element type the
            # public API reads and writes; `elem` is what the array stores.
            self.pelem = self.g.shape(t.elem)
            self.elem = self.pelem if self.pelem.data else self.g.boxed(self.pelem)
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


# Code emitted after everything else in a module: the validity predicates and
# the checked serialize stages (`reorder` still puts callees first).
TAIL = []


def emit_all(g, names, title=None, with_fuzz=True):
    PUTV_EMITTED.clear()
    TAIL.clear()
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
    w('# GENERATED by typed_object_runtime (codegen). Do not edit.')
    w('# ' + (title or 'Typed owning SSZ objects for the 109 mainnet Fulu names of'
                       ' codegen/fulu.yaml'))
    w('# Records, decode (generated validator, then generated reader), encode,')
    w('# size, root, field access, update and list append.')
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
        if with_fuzz:
            ops[n] = emit_fuzz(g, n, g.shape(t), w)
    g.fuzz_ops = ops
    lines.append('# ---- validity and checked serialize ----')
    lines.extend(TAIL)
    return '\n'.join(lines) + '\n'


# ---------------------------------------------------------------------------
# Emission helpers.

def placeholder(e):
    """What fills an unused slot of a list's storage, or stands in for an
    element taken out of it: the empty box for boxed elements, else a default
    element."""
    return 'O.BNone{}' if e.kind == 'box' else f'{e.p}_default()'


def plus(s):
    return '+' if s.data else ''


def emit_shape(s, w):
    if s.kind == 'cunion':
        emit_cunion(s, w)
        emit_dump(s, w)
        emit_valid(s, TAIL.append)
        emit_putk(s, w)
        w('')
        return
    fn = {
        'bool': emit_bool, 'u8': emit_uint, 'u16': emit_uint, 'u32': emit_uint, 'u64': emit_u64,
        'uwide': emit_rec, 'rec': emit_rec, 'fixwords': emit_words, 'bytelist': emit_words,
        'packed': emit_words, 'packed_elems': emit_words, 'bitlist': emit_bitlist,
        'seq': emit_seq, 'container': emit_container, 'box': emit_box,
    }[s.kind]
    fn(s, w)
    if s.kind != 'box':
        emit_force(s, w)
    emit_valid(s, TAIL.append)
    emit_putk(s, w)
    emit_dump(s, w)
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
    w(f'def {p}_unbox(o: {B_}) -> {R}:')
    w('  match o:')
    w(f'    case O.BSome{{{"+" if i.data else ""}v, rest}}: v')
    w(f'    case O.BNone{{}}: {i.p}_default()')
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
        w(f'def {p}_root(+hl: Nat, h: B.Buf, o: {B_}, +seg: U32) -> B.Buf & ({B_} & D.Digest):')
        w(unwrap(f'{p}_rt(v, {i.p}_root(hl, h, v, seg))', f'(h, ({p}_default(), D.zero()))'))
        w(f'def {p}_force(o: {B_}) -> {B_} & U32:')
        w(unwrap(f'({p}_wrap(v), {i.p}_force(v))', f'({p}_default(), 0)'))
        return
    w(f'def {p}_put_back(pair: Array<U32> & {R}) -> Array<U32> & {B_}:')
    w('  (out, v) = pair')
    w(f'  (out, {p}_wrap(v))')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {B_}) -> Array<U32> & {B_}:')
    w(unwrap(f'{p}_put_back({i.p}_put(out, pos, v))', f'(out, {p}_default())'))
    if not i.fixed:
        w(f'def {p}_putn_go(out: Array<U32>, v: {R}, +n: U32) -> Array<U32> & ({B_} & U32):')
        w(f'  (out, ({p}_wrap(v), n))')
        w(f'def {p}_putn_back(pair: Array<U32> & ({R} & U32)) -> Array<U32> & ({B_} & U32):')
        w('  (out, r) = pair')
        w('  (v, n) = r')
        w(f'  {p}_putn_go(out, v, n)')
        w(f'def {p}_putn(out: Array<U32>, +pos: U32, o: {B_}) -> Array<U32> & ({B_} & U32):')
        w(unwrap(f'{p}_putn_back({i.p}_putn(out, pos, v))', f'(out, ({p}_default(), 0))'))
    w(f'def {p}_size_back(pair: {R} & U32) -> {B_} & U32:')
    w('  (v, +n) = pair')
    w(f'  ({p}_wrap(v), n)')
    w(f'def {p}_size(o: {B_}) -> {B_} & U32:')
    # An absent box stays absent through the size pass (it used to come back as the default box, so the checked writer saw a present value and
    # `_serialize` accepted the object: docs/CRASH_HUNT.md CH-12); its size is 0, as nothing is written for it, and the checked writer flags it.
    w(unwrap(f'{p}_size_back({i.p}_size(v))', '(O.BNone{}, 0)'))
    w(f'def {p}_rt(pair: B.Buf & ({R} & D.Digest)) -> B.Buf & ({B_} & D.Digest):')
    w('  (h, r) = pair')
    w('  (v, d) = r')
    w(f'  (h, ({p}_wrap(v), d))')
    w(f'def {p}_root(+hl: Nat, h: B.Buf, o: {B_}, +seg: U32) -> B.Buf & ({B_} & D.Digest):')
    w(unwrap(f'{p}_rt({i.p}_root(hl, h, v, seg))', f'(h, ({p}_default(), D.zero()))'))
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


def seq_count_bound(t, e):
    """The largest count of a list of composites: its limit, and for fixed-size elements the largest count whose encoding stays below 2^31 bytes
    (n * es wraps in U32 from n >= 2^32 / es, and the size, validity and writer arithmetic is U32: docs/CRASH_HUNT.md R3-03)."""
    b = t.size
    if e.fixed and e.fsize:
        b = min(b, ((1 << 31) - 1) // e.fsize)
    return b


def append_room(n, limit):
    """The guard of an append to a list of n elements whose count can reach 2^32 - 1 (bit lists, byte lists, element arrays,
    cached lists): n < limit. The older `n + 1 <= limit` wrapped to 0 at n = 2^32 - 1 and accepted the append
    (docs/CRASH_HUNT.md CH-04); a limit that no U32 count reaches is the largest count, 2^32 - 1, itself."""
    return f'U32.is_lt({n}, {min(limit, (1 << 32) - 1)})'


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
    w('    case True{}: (buf, ' + ('False{}' if t.kind == 'vector' else 'True{}') + ')')
    w(f'    case False{{}}: {p}_head(len, off, B.read32(buf, off))')
    w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {p}_ok_nz(U32.is_eq(len, 0), buf, off, len)')


def emit_container_ok(s, w, fixed):
    p, F = s.p, s.fields
    hoff, fp = container_layout(F)
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
        is_list = t.kind in ('list', 'bytelist', 'plist')
        w(f'def {p}_len_of(pair: O.Words & U32) -> O.Words & U32:')
        w('  (o, +n) = pair')
        w(f'  (o, U32.div(n, {es}))')
        w(f'def {p}_len(o: O.Words) -> O.Words & U32: {p}_len_of(O.words_len(o))')
        if ekind == 'bool':
            w(f'def {p}_bool_at(pair: O.Words & U32) -> O.Words & Bool:')
            w('  (o, +x) = pair')
            w('  (o, U32.is_eq(x, 1))')
            rd = f'{p}_bool_at(O.words_byte_at(o, i, 1))'
            wr = 'O.words_write(o, i, O.pick(v, 1, 0), 1)'
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
        if er == 'O.Words':
            # a cell is a packed word array of exactly `es` bytes: the setter refuses any other length, and a storage smaller than
            # the cell (words_blit copies as many words as the argument claims, through the index mask; docs/CRASH_HUNT.md CH-01, R2-05)
            w(f'  {p}_set_v(i, o, n, v)')
            w(f'def {p}_set_v(+i: U32, o: O.Words, +n: U32, v: O.Words) -> O.Words & Bool:')
            w('  match v:')
            w(f'    case O.Words{{vws, +vn}}: {p}_set_w(i, o, n, vn, Array.size(U32, vws))')
            w(f'def {p}_set_w(+i: U32, o: O.Words, +n: U32, +vn: U32, pair: Array<U32> & U32) -> O.Words & Bool:')
            w('  (vws, +vc) = pair')
            w(f'  {p}_put_at(Bool.and(Bool.and({cond}, U32.is_eq(vn, {es})), U32.is_le({(es + 3) // 4}, vc)), o, i, O.Words{{vws, vn}})')
        else:
            w(f'  {p}_put_at({cond}, o, i, v)')
        w(f'def {p}_set(o: O.Words, +i: U32, {pl}v: {er}) -> O.Words & Bool: {p}_set_n(i, v, {p}_len(o))')
        if is_list:
            w(f'def {p}_grow(ok: Bool, o: O.Words, +n: U32, {pl}v: {er}) -> O.Words & Bool:')
            w('  match ok:')
            w(f'    case True{{}}: {p}_put_at(True{{}}, O.words_resize(O.words_fit(o, ((n + 1 : U32) * {es} : U32)), ((n + 1 : U32) * {es} : U32)), n, v)')
            w('    case False{}: (o, False{})')
            # every list kind: the append is guarded by a count below both the limit and the largest count whose byte length
            # (n + 1) * es, and its rounding up to a chunk (+ 31), do not wrap in U32 (CH-04, R2-01, R2-06; a limit above U32 used to leave the guard True{})
            lim_ok = append_room('n', min(t.size, ((1 << 32) - 32) // es))
            assert 'True{}' not in lim_ok, f'{p}: an unguarded append'
            acond = lim_ok if dom is None else f'Bool.and({lim_ok}, {dom})'
            w(f'def {p}_app_n({pl}v: {er}, pair: O.Words & U32) -> O.Words & Bool:')
            w('  (o, +n) = pair')
            w(f'  {p}_app_c(v, n, O.words_cap(o))')
            # the storage must hold the n elements the object claims: an append that trusted a larger claim would allocate and copy for it
            # (docs/CRASH_HUNT.md R3-02); the sum cannot wrap where the count test above passes, and its value is ignored where it fails
            store = f'U32.is_le(U32.shrn(((n * {es} : U32) + 3 : U32), 2n), sc)'
            if er == 'O.Words':
                w(f'def {p}_app_c(v: {er}, +n: U32, pair: O.Words & U32) -> O.Words & Bool:')
                w('  (o, +sc) = pair')
                w(f'  {p}_app_v(o, n, sc, v)')
                w(f'def {p}_app_v(o: O.Words, +n: U32, +sc: U32, v: O.Words) -> O.Words & Bool:')
                w('  match v:')
                w(f'    case O.Words{{vws, +vn}}: {p}_app_w(o, n, sc, vn, Array.size(U32, vws))')
                w(f'def {p}_app_w(o: O.Words, +n: U32, +sc: U32, +vn: U32, pair: Array<U32> & U32) -> O.Words & Bool:')
                w('  (vws, +vc) = pair')
                w(f'  {p}_grow(Bool.and(Bool.and(Bool.and({acond}, {store}), U32.is_eq(vn, {es})), U32.is_le({(es + 3) // 4}, vc)), o, n, O.Words{{vws, vn}})')
            else:
                w(f'def {p}_app_c({pl}v: {er}, +n: U32, pair: O.Words & U32) -> O.Words & Bool:')
                w('  (o, +sc) = pair')
                w(f'  {p}_grow(Bool.and({acond}, {store}), o, n, v)')
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
        # the storage must hold the claimed bits (docs/CRASH_HUNT.md R3-02)
        w(f'def {p}_app_n(v: Bool, pair: O.Bits & U32) -> O.Bits & Bool:')
        w('  (o, +n) = pair')
        w(f'  {p}_app_c(v, n, O.bits_cap(o))')
        w(f'def {p}_app_c(v: Bool, +n: U32, pair: O.Bits & U32) -> O.Bits & Bool:')
        w('  (o, +sc) = pair')
        w(f'  {p}_push(Bool.and({append_room("n", t.size)}, U32.is_le(U32.shrn((O.bits_nbytes(n) + 3 : U32), 2n), sc)), o, v)')
        w(f'def {p}_append(o: O.Bits, v: Bool) -> O.Bits & Bool: {p}_app_n(v, O.bits_len(o))')
        return
    if k == 'seq':
        e, S, Re, E = s.elem, f'{p}_Seq', s.elem.rep, s.elem.p
        Pe = s.pelem.rep
        boxed = e.kind == 'box'

        def wrap(v):
            return f'{E}_wrap({v})' if boxed else v

        def unbox(v):
            return f'{E}_unbox({v})' if boxed else v
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
            # a linear element is moved out (its slot keeps the empty box,
            # read back as the default element) - the affine idiom
            w(f'def {p}_at(arr: Array<{Re}>, +n: U32, +i: U32) -> {S} & Maybe<&1, {Pe}>:')
            w(f'  {p}_took(n, Array.swap({Re}, arr, i, {placeholder(e)}))')
            w(f'def {p}_took(+n: U32, pair: Array<{Re}> & {Re}) -> {S} & Maybe<&1, {Pe}>:')
            w('  (arr, v) = pair')
            w(f'  ({S}{{arr, n}}, Some{{{unbox("v")}}})')
        w(f'def {p}_get_in(inside: Bool, arr: Array<{Re}>, +n: U32, +i: U32) -> {S} & Maybe<&1, {Pe}>:')
        w('  match inside:')
        w(f'    case True{{}}: {p}_at(arr, n, i)')
        w(f'    case False{{}}: ({S}{{arr, n}}, None{{}})')
        # a linear element cannot be both returned and kept: its getter is `_take` and leaves the empty box in the slot (docs/CRASH_HUNT.md R3-01)
        gn = 'get' if e.data else 'take'
        w(f'def {p}_{gn}(o: {S}, +i: U32) -> {S} & Maybe<&1, {Pe}>:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_get_in(U32.is_lt(i, n), arr, n, i)')
        w(f'def {p}_put_in(ok: Bool, arr: Array<{Re}>, +n: U32, +i: U32, v: {Pe}) -> {S} & Bool:')
        w('  match ok:')
        w(f'    case True{{}}: ({S}{{Array.set({Re}, arr, i, {wrap("v")}), n}}, True{{}})')
        w(f'    case False{{}}: ({S}{{arr, n}}, False{{}})')
        w(f'def {p}_set(o: {S}, +i: U32, v: {Pe}) -> {S} & Bool:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_put_in(U32.is_lt(i, n), arr, n, i, v)')
        if t.kind in ('list', 'plist'):
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
            w(f'      {p}_copy(q, (i + 1 : U32), {p}_moved(i, fresh, Array.swap({Re}, old, i, {placeholder(e)})))')
            w(f'def {p}_room_pick(fits: Bool, arr: Array<{Re}>, +n: U32) -> Array<{Re}>:')
            w('  match fits:')
            w('    case True{}: arr')
            w(f'    case False{{}}: {p}_copy(U32.to_nat(n), 0, ({p}_fill({p}_cap((n + 1 : U32))), arr))')
            w(f'def {p}_room_sized(+n: U32, pair: Array<{Re}> & U32) -> Array<{Re}>:')
            w('  (arr, +cap) = pair')
            w(f'  {p}_room_pick(U32.is_lt(n, cap), arr, n)')
            w(f'def {p}_room(arr: Array<{Re}>, +n: U32) -> Array<{Re}>: {p}_room_sized(n, Array.size({Re}, arr))')
            w(f'def {p}_app_in(ok: Bool, arr: Array<{Re}>, +n: U32, v: {Pe}) -> {S} & Bool:')
            w('  match ok:')
            w(f'    case True{{}}: ({S}{{Array.set({Re}, {p}_room(arr, n), n, {wrap("v")}), (n + 1 : U32)}}, True{{}})')
            w(f'    case False{{}}: ({S}{{arr, n}}, False{{}})')
            # the append also tests that the storage holds the n elements it claims: a claim the storage cannot hold would make `room` allocate
            # and copy for the claim (docs/CRASH_HUNT.md R3-02)
            w(f'def {p}_app_sz(+n: U32, v: {Pe}, pair: Array<{Re}> & U32) -> {S} & Bool:')
            w('  (arr, +sc) = pair')
            w(f'  {p}_app_in(Bool.and({append_room("n", seq_count_bound(t, e))}, U32.is_le(n, sc)), arr, n, v)')
            w(f'def {p}_append(o: {S}, v: {Pe}) -> {S} & Bool:')
            w('  match o:')
            w(f'    case {S}{{arr, +n}}: {p}_app_sz(n, v, Array.size({Re}, arr))')
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
            w(f'def {p}_fo_nz(empty: Bool, +n: U32, +m: U32, arr: Array<{Re}>) -> {S} & U32:')
            w('  match empty:')
            w(f'    case True{{}}: ({S}{{arr, n}}, 0)')
            w(f'    case False{{}}: {p}_fo_fin(n, {p}_fo(U32.to_nat((m - 1 : U32)), 0, 0, Array.get({Re}, arr, 0)))')
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
            w(f'      {p}_fo(q, (i + 1 : U32), {p}_fo_one(i, acc, Array.swap({Re}, arr, i, {placeholder(e)})))')
            w(f'def {p}_fo_fin(+n: U32, pair: Array<{Re}> & U32) -> {S} & U32:')
            w('  (arr, +x) = pair')
            w(f'  ({S}{{arr, n}}, x)')
            w(f'def {p}_fo_nz(empty: Bool, +n: U32, +m: U32, arr: Array<{Re}>) -> {S} & U32:')
            w(f'  {p}_fo_fin(n, {p}_fo(U32.to_nat(m), 0, (arr, 0)))')
        # the fold visits the elements the storage holds, not the claimed count (docs/CRASH_HUNT.md R3-02)
        w(f'def {p}_fo_m(+n: U32, +m: U32, arr: Array<{Re}>) -> {S} & U32: {p}_fo_nz(U32.is_eq(m, 0), n, m, arr)')
        w(f'def {p}_fo_sz(+n: U32, pair: Array<{Re}> & U32) -> {S} & U32:')
        w('  (arr, +sc) = pair')
        w(f'  {p}_fo_m(n, O.pick(U32.is_le(n, sc), n, sc), arr)')
        w(f'def {p}_force(o: {S}) -> {S} & U32:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_fo_sz(n, Array.size({Re}, arr))')
    elif k == 'container':
        if len(s.fields) > GROUP:
            gs = [(f'g{g.k}', g) for g in s.groups]
            emit_force_fields(w, p, R, gs, s.data)
        else:
            emit_force_fields(w, p, R, s.fields, s.data)


def emit_dump(s, w):
    """`{p}_dump(o, t)`: the structural value dump of src/obj.bend (a test
    oracle adapter read by tools/spectests.py; never on a measured path).
    Leaves in field order, a 4-byte count before every list; it consumes the
    object."""
    p, k, R = s.p, s.kind, s.rep
    T = '+List<U32>'
    if k == 'bool':
        w(f'def {p}_dump(o: Bool, t: {T}) -> {T}: O.dump_bool(o, t)')
    elif k in ('u8', 'u16', 'u32'):
        nb = {'u8': 1, 'u16': 2, 'u32': 4}[k]
        w(f'def {p}_dump(+o: U32, t: {T}) -> {T}: O.dump_le(o, {nb}, t)')
    elif k == 'u64':
        w(f'def {p}_dump(o: O.U64, t: {T}) -> {T}: O.dump_u64(o, t)')
    elif k in ('rec', 'uwide'):
        nb = s.nbytes if k == 'rec' else s.t.size
        ws = [f'w{i}' for i in range(s.nw)]
        e = 't'
        for i in range(s.nw - 1, -1, -1):
            e = f'O.dump_le({ws[i]}, {min(4, nb - 4 * i)}, {e})'
        w(f'def {p}_dump(o: {R}, t: {T}) -> {T}:')
        w('  match o:')
        w(f'    case {R}{{' + ', '.join('+' + x for x in ws) + f'}}: {e}')
    elif k == 'fixwords':
        w(f'def {p}_dump(o: O.Words, t: {T}) -> {T}: O.dump_words(o, t)')
    elif k in ('bytelist', 'packed', 'packed_elems'):
        if s.t.kind == 'vector':
            w(f'def {p}_dump(o: O.Words, t: {T}) -> {T}: O.dump_words(o, t)')
        else:
            w(f'def {p}_dump(o: O.Words, t: {T}) -> {T}: O.dump_words_n(o, t)')
    elif k == 'bitlist':
        w(f'def {p}_dump(o: O.Bits, t: {T}) -> {T}: O.dump_bits_n(o, t)')
    elif k == 'box':
        i = s.inner
        w(f'def {p}_dump(o: {R}, t: {T}) -> {T}:')
        w('  match o:')
        w(f'    case O.BSome{{{"+" if i.data else ""}v, rest}}: {i.p}_dump(v, t)')
        w(f'    case O.BNone{{}}: {i.p}_dump({i.p}_default(), t)')
    elif k == 'seq':
        e, S, Re, E = s.elem, f'{p}_Seq', s.elem.rep, s.elem.p
        ST = f'Array<{Re}> & {T}'
        w(f'def {p}_du_took(t: {T}, pair: Array<{Re}> & {Re}) -> {ST}:')
        w(f'  (arr, {plus(e)}v) = pair')
        w(f'  (arr, {E}_dump(v, t))')
        take = (f'Array.get({Re}, arr, (i - 1 : U32))' if e.data
                else f'Array.swap({Re}, arr, (i - 1 : U32), {placeholder(e)})')
        w(f'def {p}_du(+k: Nat, +i: U32, st: {ST}) -> {ST}:')
        w('  match k:')
        w('    case 0n: st')
        w('    case 1n+q:')
        w('      (arr, t) = st')
        w(f'      {p}_du(q, (i - 1 : U32), {p}_du_took(t, {take}))')
        w(f'def {p}_du_fin(+n: U32, st: {ST}) -> {T}:')
        w('  (arr, t) = st')
        w('  t' if s.t.kind == 'vector' else '  O.dump_le(n, 4, t)')
        # the dump lists the elements the storage holds, then the claimed count (docs/CRASH_HUNT.md R3-02)
        w(f'def {p}_du_sz(+n: U32, t: {T}, pair: Array<{Re}> & U32) -> {T}:')
        w('  (arr, +sc) = pair')
        w(f'  {p}_du_m(n, O.pick(U32.is_le(n, sc), n, sc), (arr, t))')
        w(f'def {p}_du_m(+n: U32, +m: U32, st: {ST}) -> {T}: {p}_du_fin(n, {p}_du(U32.to_nat(m), m, st))')
        w(f'def {p}_dump(o: {S}, t: {T}) -> {T}:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_du_sz(n, t, Array.size({Re}, arr))')
    elif k == 'container':
        F = [(f'g{g.k}', g) for g in s.groups] if len(s.fields) > GROUP else s.fields
        emit_dump_fields(w, p, R, F)
    elif k == 'cunion':
        sels = list(s.t.selectors)
        w(f'def {p}_dump(o: {R}, t: {T}) -> {T}:')
        w('  match o:')
        for i, (_, o) in enumerate(s.options):
            w(f'    case {R}_c{i}{{{plus(o)}v}}: O.dump_le({sels[i]}, 1, {o.p}_dump(v, t))')


def emit_dump_fields(w, p, R, F):
    e = 't'
    for f, fs in reversed(F):
        e = f'{fs.p}_dump({f}, {e})'
    w(f'def {p}_dump(o: {R}, t: +List<U32>) -> +List<U32>:')
    w('  match o:')
    w(f'    case {R}{{' + ', '.join(f'{plus(fs)}{f}' for f, fs in F) + f'}}: {e}')


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
        w(f'def {p}_fo{j}(' + ', '.join(params + ['+acc: U32', f'pair: {F[i][1].rep} & U32']) + f') -> {R} & U32:')
        w(f'  ({names[i]}, +x) = pair')
        if j == len(lin) - 1:
            w(f'  ({R}{{' + ', '.join(names) + '}, (acc .^. x : U32))')
        else:
            nx = lin[j + 1]
            args = [f for k2, f in enumerate(names) if k2 != nx]
            w(f'  {p}_fo{j + 1}(' + ', '.join(args + ['(acc .^. x : U32)', f'{F[nx][1].p}_force({names[nx]})']) + ')')
    args0 = [f for k2, f in enumerate(names) if k2 != lin[0]]
    w(f'def {p}_force(o: {R}) -> {R} & U32:')
    w('  match o:')
    w(f'    case {pat}: {p}_fo0(' + ', '.join(args0 + [f'({dx} : U32)', f'{F[lin[0]][1].p}_force({names[lin[0]]})']) + ')')


# ---------------------------------------------------------------------------
# Validity of representable objects. `{p}_valid` holds exactly when the value
# is one a decoder or checked setter can produce: scalars in range, no bits
# set past a partial word, packed collections within their bounds with storage
# for their words and zero bytes past their length, every sequence element and
# boxed field present and valid. `{Name}_serialize` (emit_api) encodes only a
# valid value and refuses the rest, so an invalid object is never truncated,
# wrapped or merged into a neighbouring field.

def trivial(s):
    """Is every representable value of this shape valid?"""
    k = s.kind
    if k in ('bool', 'u32', 'u64', 'uwide'):
        return True
    if k == 'rec':
        return rec_bound(s) is None
    if k in ('container', 'group'):
        return all(trivial(fs) for _, fs in s.fields)
    return False


def rec_bound(s):
    """For a record whose last word is partial: (index, exclusive bound)."""
    t = s.t
    bits = t.size if t.kind == 'bits' else 8 * t.size
    r = bits % 32
    return None if r == 0 else (s.nw - 1, 1 << r)


def emit_valid(s, w):
    p, k, R, t = s.p, s.kind, s.rep, s.t
    if s.data and trivial(s):
        w(f'def {p}_valid({plus(s)}o: {R}) -> Bool: True{{}}')
        return
    if k == 'u8':
        w(f'def {p}_valid(+o: U32) -> Bool: U32.is_le(o, 255)')
    elif k == 'u16':
        w(f'def {p}_valid(+o: U32) -> Bool: U32.is_le(o, 65535)')
    elif k == 'rec':
        i, bound = rec_bound(s)
        ws = [f'w{j}' for j in range(s.nw)]
        w(f'def {p}_valid(o: {R}) -> Bool:')
        w('  match o:')
        w(f'    case {R}{{' + ', '.join('+' + y for y in ws) + f'}}: U32.is_lt(w{i}, {bound})')
    elif k in ('fixwords', 'bytelist', 'packed', 'packed_elems'):
        if k == 'fixwords':
            nb = t.size if t.kind == 'bytes' else (t.size + 7) // 8
            lo, hi, big, unit = nb, nb, 'False{}', 1
        elif k == 'bytelist':
            lim, big = u32_limit(t.size)
            lo, hi, unit = 0, lim, 1
        else:
            es = t.elem.fixed_size()
            if t.kind == 'vector':
                lo, hi, big = t.size * es, t.size * es, 'False{}'
            elif t.kind == 'plist':
                lo, hi, big = 0, 0, 'True{}'
            else:
                lim, big = u32_limit(t.size * es)
                lo, hi = 0, lim
            unit = es
        call = f'O.words_ok(o, {lo}, {hi}, {big}, {unit})'
        if k == 'packed' and t.elem.kind == 'bool':
            call = f'O.bools_ok({call})'
        if k == 'fixwords' and t.kind == 'bits' and t.size % 32:
            # the bits of the last word past the vector's length are zero
            call = f'O.bitvec_tail({t.size}, {call})'
        w(f'def {p}_valid(o: O.Words) -> O.Words & Bool: {call}')
    elif k == 'bitlist':
        if t.kind == 'pbits':
            lim, big = 0, 'True{}'
        else:
            lim, big = u32_limit(t.size)
        w(f'def {p}_valid(o: O.Bits) -> O.Bits & Bool: O.bits_ok(o, {lim}, {big})')
    elif k == 'box':
        i = s.inner
        B_ = s.rep
        w(f'def {p}_va_back(pair: {i.rep} & Bool) -> {B_} & Bool:')
        w('  (v, ok) = pair')
        w(f'  (O.BSome{{v, O.BNone{{}}}}, ok)')
        w(f'def {p}_valid(o: {B_}) -> {B_} & Bool:')
        w('  match o:')
        if i.data:
            w(f'    case O.BSome{{+v, rest}}: (O.BSome{{v, O.BNone{{}}}}, {i.p}_valid(v))')
        else:
            w(f'    case O.BSome{{v, rest}}: {p}_va_back({i.p}_valid(v))')
        w(f'    case O.BNone{{}}: (O.BNone{{}}, False{{}})')
    elif k == 'seq':
        e, S, Re, E = s.elem, f'{p}_Seq', s.elem.rep, s.elem.p
        if t.kind == 'vector':
            cnt = f'U32.is_eq(n, {t.size})'
        elif t.kind == 'plist':
            cnt = 'True{}'
        else:
            lim, big = u32_limit(t.size)
            cnt = f'Bool.or({big}, U32.is_le(n, {lim}))'
        if e.data and trivial(e):
            w(f'def {p}_va_cap(ok: Bool, +n: U32, pair: Array<{Re}> & U32) -> {S} & Bool:')
            w('  (arr, +c) = pair')
            w(f'  ({S}{{arr, n}}, Bool.and(ok, U32.is_le(n, c)))')
            w(f'def {p}_valid(o: {S}) -> {S} & Bool:')
            w('  match o:')
            w(f'    case {S}{{arr, +n}}: {p}_va_cap({cnt}, n, Array.size({Re}, arr))')
            return
        if e.data:
            w(f'def {p}_va(+k: Nat, +i: U32, acc: Bool, pair: Array<{Re}> & {Re}) -> Array<{Re}> & Bool:')
            w('  match k:')
            w('    case 0n:')
            w('      (arr, +v) = pair')
            w(f'      (arr, Bool.and(acc, {E}_valid(v)))')
            w('    case 1n+q:')
            w('      (arr, +v) = pair')
            w(f'      {p}_va(q, (i + 1 : U32), Bool.and(acc, {E}_valid(v)), Array.get({Re}, arr, (i + 1 : U32)))')
            w(f'def {p}_va_nz(empty: Bool, +n: U32, arr: Array<{Re}>) -> Array<{Re}> & Bool:')
            w('  match empty:')
            w('    case True{}: (arr, True{})')
            w(f'    case False{{}}: {p}_va(U32.to_nat((n - 1 : U32)), 0, True{{}}, Array.get({Re}, arr, 0))')
        else:
            w(f'def {p}_va_back(+i: U32, acc: Bool, arr: Array<{Re}>, pair: {Re} & Bool) -> Array<{Re}> & Bool:')
            w('  (v, ok) = pair')
            w(f'  (Array.set({Re}, arr, i, v), Bool.and(acc, ok))')
            w(f'def {p}_va_one(+i: U32, acc: Bool, pair: Array<{Re}> & {Re}) -> Array<{Re}> & Bool:')
            w('  (arr, v) = pair')
            w(f'  {p}_va_back(i, acc, arr, {E}_valid(v))')
            w(f'def {p}_va(+k: Nat, +i: U32, pair: Array<{Re}> & Bool) -> Array<{Re}> & Bool:')
            w('  match k:')
            w('    case 0n: pair')
            w('    case 1n+q:')
            w('      (arr, acc) = pair')
            w(f'      {p}_va(q, (i + 1 : U32), {p}_va_one(i, acc, Array.swap({Re}, arr, i, {placeholder(e)})))')
            w(f'def {p}_va_nz(empty: Bool, +n: U32, arr: Array<{Re}>) -> Array<{Re}> & Bool:')
            w(f'  {p}_va(U32.to_nat(n), 0, (arr, True{{}}))')
        # capacity first: the element scan reads only indices below n
        w(f'def {p}_va_fin(+n: U32, ok: Bool, pair: Array<{Re}> & Bool) -> {S} & Bool:')
        w('  (arr, b) = pair')
        w(f'  ({S}{{arr, n}}, Bool.and(ok, b))')
        w(f'def {p}_va_go(ok: Bool, +n: U32, arr: Array<{Re}>) -> {S} & Bool:')
        w('  match ok:')
        w(f'    case True{{}}: {p}_va_fin(n, True{{}}, {p}_va_nz(U32.is_eq(n, 0), n, arr))')
        w(f'    case False{{}}: ({S}{{arr, n}}, False{{}})')
        w(f'def {p}_va_cap(ok: Bool, +n: U32, pair: Array<{Re}> & U32) -> {S} & Bool:')
        w('  (arr, +c) = pair')
        w(f'  {p}_va_go(Bool.and(ok, U32.is_le(n, c)), n, arr)')
        w(f'def {p}_valid(o: {S}) -> {S} & Bool:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_va_cap({cnt}, n, Array.size({Re}, arr))')
    elif k == 'container':
        F = [(f'g{g.k}', g) for g in s.groups] if len(s.fields) > GROUP else s.fields
        emit_valid_fields(w, p, R, F, s.data)
    elif k == 'cunion':
        opts = s.options
        for i, (_, o) in enumerate(opts):
            if o.data:
                continue
            w(f'def {p}_va{i}(pair: {o.rep} & Bool) -> {R} & Bool:')
            w('  (v, ok) = pair')
            w(f'  ({R}_c{i}{{v}}, ok)')
        w(f'def {p}_valid(o: {R}) -> {R} & Bool:')
        w('  match o:')
        for i, (_, o) in enumerate(opts):
            if o.data:
                w(f'    case {R}_c{i}{{+v}}: ({R}_c{i}{{v}}, {o.p}_valid(v))')
            else:
                w(f'    case {R}_c{i}{{v}}: {p}_va{i}({o.p}_valid(v))')
    else:
        raise ValueError(f'{p}: no validity for kind {k}')


def emit_valid_fields(w, p, R, F, data):
    names = [f for f, _ in F]
    pat = f'{R}{{' + ', '.join(f'{plus(fs)}{f}' for f, fs in F) + '}'
    def conj(xs):
        x = 'True{}'
        for y in reversed(xs):
            x = y if x == 'True{}' else f'Bool.and({y}, {x})'
        return x
    dvs = [f'{fs.p}_valid({f})' for f, fs in F if fs.data and not trivial(fs)]
    if data:
        w(f'def {p}_valid(o: {R}) -> Bool:')
        w('  match o:')
        w(f'    case {pat}: {conj(dvs)}')
        return
    lin = [i for i, (f, fs) in enumerate(F) if not fs.data]
    dx = conj(dvs)
    for j in range(len(lin) - 1, -1, -1):
        i = lin[j]
        params = [f'{plus(fs)}{f}: {fs.rep}' for k2, (f, fs) in enumerate(F) if k2 != i]
        w(f'def {p}_va{j}(' + ', '.join(params + ['acc: Bool', f'pair: {F[i][1].rep} & Bool']) + f') -> {R} & Bool:')
        w(f'  ({names[i]}, ok) = pair')
        if j == len(lin) - 1:
            w(f'  ({R}{{' + ', '.join(names) + '}, Bool.and(acc, ok))')
        else:
            nx = lin[j + 1]
            args = [f for k2, f in enumerate(names) if k2 != nx]
            w(f'  {p}_va{j + 1}(' + ', '.join(args + ['Bool.and(acc, ok)', f'{F[nx][1].p}_valid({names[nx]})']) + ')')
    args0 = [f for k2, f in enumerate(names) if k2 != lin[0]]
    w(f'def {p}_valid(o: {R}) -> {R} & Bool:')
    w('  match o:')
    w(f'    case {pat}: {p}_va0(' + ', '.join(args0 + [dx, f'{F[lin[0]][1].p}_valid({names[lin[0]]})']) + ')')


def emit_putk(s, w):
    """`{p}_putk`: the checked writer of a linear shape (see emit_fieldset).
    A leaf, sequence or union is checked by its own `{p}_valid` - a pass over
    that value alone, never its parent's record - and then written; a box
    checks presence and hands the check of its content to the content's
    writer. Containers and groups emit theirs with their put chain."""
    p, k, R = s.p, s.kind, s.rep
    if s.data or k == 'container':
        return
    if k == 'box':
        i, B_ = s.inner, s.rep
        w(f'def {p}_pk_back(pair: Array<U32> & ({i.rep} & U32)) -> Array<U32> & ({B_} & U32):')
        w('  (out, r) = pair')
        w('  (v, m) = r')
        w(f'  (out, (O.BSome{{v, O.BNone{{}}}}, m))')
        w(f'def {p}_putk(out: Array<U32>, +pos: U32, o: {B_}) -> Array<U32> & ({B_} & U32):')
        w('  match o:')
        if i.data:
            w(f'    case O.BSome{{+v, rest}}: ({i.p}_put(out, pos, v), (O.BSome{{v, O.BNone{{}}}}, O.pz({i.p}_valid(v))))')
        else:
            w(f'    case O.BSome{{v, rest}}: {p}_pk_back({i.p}_putk(out, pos, v))')
        w('    case O.BNone{}: (out, (O.BNone{}, 4294967295))')
        return
    variable = not s.fixed
    w(f'def {p}_pk(out: Array<U32>, +pos: U32, pair: {R} & Bool) -> Array<U32> & ({R} & U32):')
    w('  (o, ok) = pair')
    w('  match ok:')
    if variable:
        w(f'    case True{{}}: {p}_putn(out, pos, o)')
    else:
        w(f'    case True{{}}: {p}_pk_ok({p}_put(out, pos, o))')
    w('    case False{}: (out, (o, 4294967295))')
    if not variable:
        w(f'def {p}_pk_ok(pair: Array<U32> & {R}) -> Array<U32> & ({R} & U32):')
        w('  (out, o) = pair')
        w('  (out, (o, 0))')
    w(f'def {p}_putk(out: Array<U32>, +pos: U32, o: {R}) -> Array<U32> & ({R} & U32): {p}_pk(out, pos, {p}_valid(o))')


def emit_bool(s, w):
    p = s.p
    w(f'def {p}_default() -> Bool: False{{}}')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: O.rd_bool(buf, off)')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: Bool) -> Array<U32>: O.wbool(out, pos, o)')
    w(f'def {p}_root(+hl: Nat, h: B.Buf, o: Bool, +seg: U32) -> B.Buf & D.Digest: (h, O.bool_chunk(o))')


def emit_uint(s, w):
    p, n = s.p, s.t.size
    rd = {1: 'O.rd_u8', 2: 'O.rd_u16', 4: 'O.rd_u32'}[n]
    wr = {1: 'O.w8', 2: 'O.w16', 4: 'O.w32'}[n]
    w(f'def {p}_default() -> U32: 0')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & U32: {rd}(buf, off)')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, +o: U32) -> Array<U32>: {wr}(out, pos, o)')
    w(f'def {p}_root(+hl: Nat, h: B.Buf, +o: U32, +seg: U32) -> B.Buf & D.Digest: (h, O.u32_chunk(o))')


def emit_u64(s, w):
    p = s.p
    w(f'def {p}_default() -> O.U64: O.u64_zero()')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.U64: O.rd_u64(buf, off)')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: O.U64) -> Array<U32>: O.w64(out, pos, o)')
    w(f'def {p}_root(+hl: Nat, h: B.Buf, o: O.U64, +seg: U32) -> B.Buf & D.Digest: (h, O.u64_chunk(o))')


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
    emit_rec_put(p, R, ws, w, nb)
    # root: chunks of eight big-endian words, zero padded, in a complete tree
    nc = chunks_of(nb)
    leaves = []
    for c in range(nc):
        wsw = [f'B.swap32({ws[8 * c + j]})' if 8 * c + j < nw else '0' for j in range(8)]
        leaves.append('D.D{' + ', '.join(wsw) + '}')
    w(f'def {p}_root(+hl: Nat, h: B.Buf, o: {R}, +seg: U32) -> B.Buf & D.Digest:')
    w('  match o:')
    w(f'    case {pat}: (h, {tree(leaves)})')


def emit_rec_put(p, R, ws, w, nbytes):
    """Write a word record's bytes at an arbitrary byte position.

    The destination alignment is the same for every word of the record, so it
    is decided once and the run then uses constant shifts: writing each word
    on its own re-tested the alignment and, when unaligned, paid two
    read-modify-writes and two loop-driven variable shifts per word. The bytes
    written and the OR semantics are exactly the same as the per-word writer's:
    destination word q+j receives (w_j << 8s) | (w_{j-1} >> (32-8s)).
    """
    n = len(ws)
    pat = f'{R}{{' + ', '.join('+' + x for x in ws) + '}'
    params = ', '.join(f'+{x}: U32' for x in ws)
    args = ', '.join(ws)
    e = 'out'
    for j, x in enumerate(ws):
        if j == n - 1 and nbytes % 4:
            # the last word holds fewer than four of the record's bytes; the
            # rest belong to the next value, so it is OR-ed in, not stored
            e = f'O.or_word({e}, (q + {j} : U32), {x})'
        else:
            e = f'Array.set(U32, {e}, (q + {j} : U32), {x})'
    w(f'def {p}_pw0(out: Array<U32>, +q: U32, {params}) -> Array<U32>: {e}')
    for s, mul, sh in ((1, 256, 24), (2, 65536, 16), (3, 16777216, 8)):
        e = 'out'
        for j in range(n + 1):
            lo = f'({ws[j]} * {mul} : U32)' if j < n else None
            hi = f'U32.shrn({ws[j - 1]}, {sh}n)' if j > 0 else None
            val = f'({lo} .|. {hi} : U32)' if (lo and hi) else (lo or hi)
            if j == n:
                # the trailing carry word: written only when it carries bytes,
                # so the output needs no spare word past the data
                e = f'O.or_skip({e}, (q + {j} : U32), {val})'
            elif 1 <= j and 4 * j + 4 - s <= nbytes:
                # destination word q+j lies wholly inside the record's own
                # bytes [p, p + nbytes): no neighbour shares it, so it is
                # stored, not OR-ed into (the same bytes: the output is zero)
                e = f'Array.set(U32, {e}, (q + {j} : U32), {val})'
            else:
                e = f'O.or_word({e}, (q + {j} : U32), {val})'
        w(f'def {p}_pw{s}(out: Array<U32>, +q: U32, {params}) -> Array<U32>: {e}')
    # The aligned case is the common one (every fixed layout of a word-sized
    # field at a word-aligned container position); it is tested by one
    # comparison and the three shifted writers sit behind a separate function,
    # so the aligned path stays small enough to be inlined into its caller.
    w(f'def {p}_pwu(+s: U32, out: Array<U32>, +q: U32, {params}) -> Array<U32>:')
    w('  match s:')
    w(f'    case 1: {p}_pw1(out, q, {args})')
    w(f'    case 2: {p}_pw2(out, q, {args})')
    w(f'    case _: {p}_pw3(out, q, {args})')
    w(f'def {p}_pwd(aligned: Bool, +s: U32, out: Array<U32>, +q: U32, {params}) -> Array<U32>:')
    w('  match aligned:')
    w(f'    case True{{}}: {p}_pw0(out, q, {args})')
    w(f'    case False{{}}: {p}_pwu(s, out, q, {args})')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {R}) -> Array<U32>:')
    w('  match o:')
    w(f'    case {pat}: {p}_pwd(U32.is_eq((pos .&. 3 : U32), 0), (pos .&. 3 : U32), out, U32.shrn(pos, 2n), {args})')


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
            nxt.append(f'D.node(hl, {a}, {b})')
        level = nxt
    return level[0]


def words_depth_for(nb):
    """O.depth_for(nb): the depth of a Words holding nb bytes (whole chunks
    plus one spare chunk)."""
    return cap_depth(4 * (((nb + 31) // 32) * 8 + 8))


def emit_words(s, w):
    """Packed little-endian bytes: large byte/bit vectors, byte lists, packed lists."""
    p, t, k = s.p, s.t, s.kind
    if k == 'fixwords':
        nb = t.size if t.kind == 'bytes' else (t.size + 7) // 8
        w(f'def {p}_default() -> O.Words: O.words_new({nb})')
        w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: '
          f'O.copy_into(buf, off, {nb}, Array.new(U32, {words_depth_for(nb)}n, 0))')
        depth = log2ceil(chunks_of(nb))
        root = f'O.words_root(hl, h, o, {depth}, seg)'
    elif k == 'bytelist':
        w(f'def {p}_default() -> O.Words: O.words_new(0)')
        w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, len)')
        core = ('O.words_root_prog(hl, h, o, seg)' if s.prog
                else f'O.words_root(hl, h, o, {log2ceil(chunks_of(t.size))}, seg)')
        root = f'O.mix_count(hl, 0n, {core})'
    else:
        e = t.elem
        es = e.fixed_size()
        count = t.size
        if t.kind == 'vector':
            w(f'def {p}_default() -> O.Words: O.words_new({count * es})')
            w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: '
              f'O.copy_into(buf, off, {count * es}, Array.new(U32, {words_depth_for(count * es)}n, 0))')
        else:
            w(f'def {p}_default() -> O.Words: O.words_new(0)')
            w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Words: O.copy_in(buf, off, len)')
        if k == 'packed':
            core = ('O.words_root_prog(hl, h, o, seg)' if s.prog
                    else f'O.words_root(hl, h, o, {log2ceil(chunks_of(count * es))}, seg)')
        else:
            ew = es // 4
            ed = log2ceil(chunks_of(es))
            core = (f'O.elems_root_prog(hl, h, o, {ew}, {ed}, seg)' if s.prog
                    else f'O.elems_root(hl, h, o, {ew}, {ed}, {log2ceil(count)}, seg)')
        if t.kind == 'vector':
            root = core
        else:
            shift = {1: 0, 2: 1, 4: 2, 8: 3, 16: 4, 32: 5}.get(es)
            if shift is None:
                root = f'{p}_mix(hl, {core})'
                w(f'def {p}_mix(+hl: Nat, pair: B.Buf & (O.Words & D.Digest)) -> B.Buf & (O.Words & D.Digest):')
                w('  (h, r) = pair')
                w('  (o, d) = r')
                w('  match o:')
                w(f'    case O.Words{{ws, +n}}: (h, (O.Words{{ws, n}}, O.mix_len(hl, d, U32.div(n, {es}))))')
            else:
                root = f'O.mix_count(hl, {shift}n, {core})'
    w(f'def {p}_size(o: O.Words) -> O.Words & U32: O.words_sizek(o)')
    fixed_nb = s.fsize if s.fixed else None
    if fixed_nb is not None and fixed_nb % 4 == 0 and fixed_nb // 4 <= FIXED_COPY_MAX_WORDS:
        # A short fixed-size run (a signature, a pubkey, a proof branch) at a
        # word-aligned position: its words are moved by straight-line reads
        # and stores, with no loop; any other position takes the general
        # writer. The same words are written either way.
        nw = fixed_nb // 4
        for k in range(nw - 1, -1, -1):
            nxt = (f'{p}_pa{k + 1}(q, Array.set(U32, out, (q + {k} : U32), w), Array.get(U32, ws, {k + 1}))'
                   if k < nw - 1 else f'(Array.set(U32, out, (q + {k} : U32), w), ws)')
            w(f'def {p}_pa{k}(+q: U32, out: Array<U32>, pair: Array<U32> & U32) -> Array<U32> & Array<U32>:')
            w('  (ws, +w) = pair')
            w(f'  {nxt}')
        w(f'def {p}_pal(+n: U32, pair: Array<U32> & Array<U32>) -> Array<U32> & O.Words:')
        w('  (out, ws) = pair')
        w('  (out, O.Words{ws, n})')
        w(f'def {p}_pw(aligned: Bool, out: Array<U32>, +pos: U32, ws: Array<U32>, +n: U32) -> Array<U32> & O.Words:')
        w('  match aligned:')
        w(f'    case True{{}}: {p}_pal(n, {p}_pa0(U32.shrn(pos, 2n), out, Array.get(U32, ws, 0)))')
        w('    case False{}: O.put_words(out, pos, O.Words{ws, n})')
        w(f'def {p}_put(out: Array<U32>, +pos: U32, o: O.Words) -> Array<U32> & O.Words:')
        w('  match o:')
        w(f'    case O.Words{{ws, +n}}: {p}_pw(U32.is_eq((pos .&. 3 : U32), 0), out, pos, ws, n)')
    else:
        w(f'def {p}_put(out: Array<U32>, +pos: U32, o: O.Words) -> Array<U32> & O.Words: O.put_words(out, pos, o)')
    if not s.fixed:
        w(f'def {p}_putn(out: Array<U32>, +pos: U32, o: O.Words) -> Array<U32> & (O.Words & U32): '
          f'O.put_words_n(out, pos, o)')
    w(f'def {p}_root(+hl: Nat, h: B.Buf, o: O.Words, +seg: U32) -> B.Buf & (O.Words & D.Digest): {root}')


def emit_bitlist(s, w):
    p, t = s.p, s.t
    w(f'def {p}_default() -> O.Bits: O.Bits{{Array.new(U32, 3n, 0), 0}}')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & O.Bits: O.bits_in(buf, off, len)')
    w(f'def {p}_size(o: O.Bits) -> O.Bits & U32: O.bits_sizek(o)')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: O.Bits) -> Array<U32> & O.Bits: O.put_bits(out, pos, o)')
    w(f'def {p}_putn(out: Array<U32>, +pos: U32, o: O.Bits) -> Array<U32> & (O.Bits & U32): O.put_bits_n(out, pos, o)')
    root = ('O.bits_root_prog(hl, h, o, seg)' if s.prog
            else f'O.bits_root(hl, h, o, {log2ceil(chunks_of((t.size + 7) // 8))}, seg)')
    w(f'def {p}_root(+hl: Nat, h: B.Buf, o: O.Bits, +seg: U32) -> B.Buf & (O.Bits & D.Digest): {root}')


# ---------------------------------------------------------------------------
# Sequences of composite elements: an array of element objects and a count.

def _seq_fixed_reader(w, p, e, R, E, S, is_list, count):
    """the reader of a sequence of fixed-size elements: the read loop, its finish and the count/length checks"""
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


def _seq_size_put(w, p, e, R, E, S):
    """the sequence's size pass and writer, for fixed-size and variable-size elements"""
    if e.fixed:
        es = e.fsize
        w(f'def {p}_size(o: {S}) -> {S} & U32:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_szf(n, Array.size({R}, arr))')
        # the size of storage that does not hold n elements is refused (bit 31)
        w(f'def {p}_szf(+n: U32, pair: Array<{R}> & U32) -> {S} & U32:')
        w('  (arr, +c) = pair')
        w(f'  ({S}{{arr, n}}, O.pick(Bool.and(U32.is_le(n, c), U32.is_le(n, {((1 << 32) - 2) // es})), (n * {es} : U32), 4294967295))')
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
            # linear fixed-size elements (a Deposit's proof is packed words),
            # taken out and put back with one spare element for the loop
            PT = f'Array<U32> & (Array<{R}> & {R})'
            w(f'def {p}_pt_ret(out: Array<U32>, pair: Array<{R}> & {R}) -> {PT}:')
            w('  (arr, sp) = pair')
            w('  (out, (arr, sp))')
            w(f'def {p}_pt_back(+i: U32, arr: Array<{R}>, pair: Array<U32> & {R}) -> {PT}:')
            w('  (out, v) = pair')
            w(f'  {p}_pt_ret(out, Array.swap({R}, arr, i, v))')
            w(f'def {p}_pt_one(+i: U32, +pos: U32, out: Array<U32>, pair: Array<{R}> & {R}) -> {PT}:')
            w('  (arr, v) = pair')
            w(f'  {p}_pt_back(i, arr, {E}_put(out, (pos + i * {es} : U32), v))')
            w(f'def {p}_pt(+k: Nat, +i: U32, +pos: U32, st: {PT}) -> {PT}:')
            w('  match k:')
            w('    case 0n: st')
            w('    case 1n+q:')
            w('      (out, r) = st')
            w('      (arr, sp) = r')
            w(f'      {p}_pt(q, (i + 1 : U32), pos, {p}_pt_one(i, pos, out, Array.swap({R}, arr, i, sp)))')
            w(f'def {p}_pt_fin(+n: U32, st: {PT}) -> Array<U32> & {S}:')
            w('  (out, r) = st')
            w('  (arr, sp) = r')
            w(f'  (out, {S}{{arr, n}})')
            w(f'def {p}_pt_nz(empty: Bool, +pos: U32, +n: U32, out: Array<U32>, arr: Array<{R}>) -> Array<U32> & {S}:')
            w('  match empty:')
            w(f'    case True{{}}: (out, {S}{{arr, n}})')
            w(f'    case False{{}}: {p}_pt_fin(n, {p}_pt(U32.to_nat(n), 0, pos, (out, (arr, {placeholder(e)}))))')
    else:
        # variable-size elements: element sizes first (for the offsets), then
        # offsets and elements in one pass tracking the running offset.
        # Each element is taken out of the array by a swap with a spare
        # element and put back by a second swap that returns the spare, so
        # one default element serves the whole loop (built only for a
        # nonempty list) instead of one being built and dropped per element.
        SP = f'Array<{R}> & (U32 & {R})'
        w(f'def {p}_sz_ret(+acc: U32, pair: Array<{R}> & {R}) -> {SP}:')
        w('  (arr, sp) = pair')
        w('  (arr, (acc, sp))')
        w(f'def {p}_sz_back(+i: U32, +acc: U32, arr: Array<{R}>, pair: {R} & U32) -> {SP}:')
        w('  (v, +m) = pair')
        w(f'  {p}_sz_ret(O.padd(acc, m), Array.swap({R}, arr, i, v))')
        w(f'def {p}_sz_one(+i: U32, +acc: U32, pair: Array<{R}> & {R}) -> {SP}:')
        w('  (arr, v) = pair')
        w(f'  {p}_sz_back(i, acc, arr, {E}_size(v))')
        w(f'def {p}_sz(+k: Nat, +i: U32, st: {SP}) -> {SP}:')
        w('  match k:')
        w('    case 0n: st')
        w('    case 1n+q:')
        w('      (arr, r) = st')
        w('      (acc, sp) = r')
        w(f'      {p}_sz(q, (i + 1 : U32), {p}_sz_one(i, acc, Array.swap({R}, arr, i, sp)))')
        w(f'def {p}_sz_fin(+n: U32, st: {SP}) -> {S} & U32:')
        w('  (arr, r) = st')
        w('  (m, sp) = r')
        w(f'  ({S}{{arr, n}}, O.padd((4 * n : U32), m))')
        w(f'def {p}_sz_nz(empty: Bool, arr: Array<{R}>, +n: U32) -> {S} & U32:')
        w('  match empty:')
        w(f'    case True{{}}: ({S}{{arr, n}}, 0)')
        w(f'    case False{{}}: {p}_sz_fin(n, {p}_sz(U32.to_nat(n), 0, (arr, (0, {placeholder(e)}))))')
        # storage that does not hold n elements: refused (bit 31), no loop
        w(f'def {p}_sz_ok(ok: Bool, arr: Array<{R}>, +n: U32) -> {S} & U32:')
        w('  match ok:')
        w(f'    case True{{}}: {p}_sz_nz(U32.is_eq(n, 0), arr, n)')
        w(f'    case False{{}}: ({S}{{arr, n}}, 4294967295)')
        w(f'def {p}_sz_cap(+n: U32, pair: Array<{R}> & U32) -> {S} & U32:')
        w('  (arr, +c) = pair')
        w(f'  {p}_sz_ok(U32.is_le(n, c), arr, n)')
        w(f'def {p}_size(o: {S}) -> {S} & U32:')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_sz_cap(n, Array.size({R}, arr))')
        # put: state (out, (arr, (cur, spare))); element i: write its offset
        # (cur) and the element at pos + cur, put it back, advance cur.
        PS = f'Array<U32> & (Array<{R}> & (U32 & {R}))'
        putv = putv_helper(e, w)
        w(f'def {p}_pv_ret(out: Array<U32>, c: U32, pair: Array<{R}> & {R}) -> {PS}:')
        w('  (arr, sp) = pair')
        w('  (out, (arr, (c, sp)))')
        w(f'def {p}_pv_placed(+i: U32, arr: Array<{R}>, pair: Array<U32> & ({R} & U32)) -> {PS}:')
        w('  (out, r) = pair')
        w('  (v, c) = r')
        w(f'  {p}_pv_ret(out, c, Array.swap({R}, arr, i, v))')
        w(f'def {p}_pv_one(+i: U32, +pos: U32, +cur: U32, out: Array<U32>, pair: Array<{R}> & {R}) -> {PS}:')
        w('  (arr, v) = pair')
        w(f'  {p}_pv_placed(i, arr, {putv}(out, pos, (4 * i : U32), cur, v))')
        w(f'def {p}_pv(+k: Nat, +i: U32, +pos: U32, st: {PS}) -> {PS}:')
        w('  match k:')
        w('    case 0n: st')
        w('    case 1n+q:')
        w('      (out, s1) = st')
        w('      (arr, s2) = s1')
        w('      (cur, sp) = s2')
        w(f'      {p}_pv(q, (i + 1 : U32), pos, {p}_pv_one(i, pos, cur, out, Array.swap({R}, arr, i, sp)))')
        w(f'def {p}_pvn_go(+n: U32, out: Array<U32>, arr: Array<{R}>, +cur: U32) -> Array<U32> & ({S} & U32):')
        w(f'  (out, ({S}{{arr, n}}, cur))')
        w(f'def {p}_pvn_fin(+n: U32, st: {PS}) -> Array<U32> & ({S} & U32):')
        w('  (out, s1) = st')
        w('  (arr, s2) = s1')
        w('  (cur, sp) = s2')
        w(f'  {p}_pvn_go(n, out, arr, cur)')
        w(f'def {p}_pvn_nz(empty: Bool, out: Array<U32>, +pos: U32, arr: Array<{R}>, +n: U32) -> Array<U32> & ({S} & U32):')
        w('  match empty:')
        w(f'    case True{{}}: (out, ({S}{{arr, n}}, 0))')
        w(f'    case False{{}}: {p}_pvn_fin(n, {p}_pv(U32.to_nat(n), 0, pos, (out, (arr, ((4 * n : U32), {placeholder(e)})))))')
        w(f'def {p}_putn(out: Array<U32>, +pos: U32, o: {S}) -> Array<U32> & ({S} & U32):')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_pvn_nz(U32.is_eq(n, 0), out, pos, arr, n)')
        w(f'def {p}_pv_drop(pair: Array<U32> & ({S} & U32)) -> Array<U32> & {S}:')
        w('  (out, r) = pair')
        w('  (sq, m) = r')
        w('  (out, sq)')
        w(f'def {p}_pt_nz(empty: Bool, +pos: U32, +n: U32, out: Array<U32>, arr: Array<{R}>) -> Array<U32> & {S}:')
        w(f'  {p}_pv_drop({p}_pvn_nz(empty, out, pos, arr, n))')


def _seq_root_tree(w, p, t, e, R, E):
    """the root: the recursive tree over the element roots"""
    lim = log2ceil(t.size)
    ST = f'B.Buf & (Array<{R}> & D.Digest)'
    if e.data:
        w(f'def {p}_rl_d(arr: Array<{R}>, pair: B.Buf & D.Digest) -> {ST}:')
        w('  (h, d) = pair')
        w('  (h, (arr, d))')
        w(f'def {p}_rl(+hl: Nat, +seg: U32, h: B.Buf, pair: Array<{R}> & {R}) -> {ST}:')
        w('  (arr, +v) = pair')
        w(f'  {p}_rl_d(arr, {E}_root(hl, h, v, (seg + 64 : U32)))')
        leaf = f'{p}_rl(hl, seg, h, Array.get({R}, arr, U32.from_nat(s)))'
    else:
        w(f'def {p}_rl_n(+i: U32, arr: Array<{R}>, pair: B.Buf & ({R} & D.Digest)) -> {ST}:')
        w('  (h, r) = pair')
        w('  (v, d) = r')
        w(f'  (h, (Array.set({R}, arr, i, v), d))')
        w(f'def {p}_rl(+hl: Nat, +i: U32, +seg: U32, h: B.Buf, pair: Array<{R}> & {R}) -> {ST}:')
        w('  (arr, v) = pair')
        w(f'  {p}_rl_n(i, arr, {E}_root(hl, h, v, (seg + 64 : U32)))')
        leaf = f'{p}_rl(hl, U32.from_nat(s), seg, h, Array.swap({R}, arr, U32.from_nat(s), {placeholder(e)}))'
    w(f'def {p}_mj(+hl: Nat, dl: D.Digest, pair: {ST}) -> {ST}:')
    w('  (h, r) = pair')
    w('  (arr, dr) = r')
    w('  (h, (arr, D.node(hl, dl, dr)))')
    w(f'def {p}_mt(d: Nat, m: Nat, inside: Bool, +hl: Nat, +seg: U32, +w: Nat, +s: Nat, +n: Nat, st: {ST}) -> {ST}:')
    w('  match d:')
    w('    case 0n:')
    w('      match m:')
    w('        case 0n:')
    w('          match inside:')
    w('            case False{}:')
    w('              (h, r) = st')
    w('              (arr, dl) = r')
    w('              (h, (arr, D.zconst(0n)))')
    w('            case True{}:')
    w('              (h, r) = st')
    w('              (arr, dl) = r')
    w(f'              {leaf}')
    w('        case 1n+q:')
    w('          (h, r) = st')
    w('          (arr, dl) = r')
    w(f'          {p}_mj(hl, dl, {p}_mt(0n, q, inside, hl, seg, w, s, n, (h, (arr, D.zero()))))')
    w('    case 1n+ +p:')
    w('      match m:')
    w('        case 0n:')
    w('          match inside:')
    w('            case False{}:')
    w('              (h, r) = st')
    w('              (arr, dl) = r')
    w('              (h, (arr, D.zconst(1n+p)))')
    w('            case True{}:')
    w(f'              {p}_mt(p, 1n, Nat.is_lt(Nat.add(s, Nat.div(w, 2n)), n), hl, seg, Nat.div(w, 2n), Nat.add(s, Nat.div(w, 2n)), n,')
    w(f'                {p}_mt(p, 0n, True{{}}, hl, seg, Nat.div(w, 2n), s, n, st))')
    w('        case 1n+q:')
    w('          (h, r) = st')
    w('          (arr, dl) = r')
    w(f'          {p}_mj(hl, dl, {p}_mt(1n+p, q, inside, hl, seg, w, s, n, (h, (arr, D.zero()))))')
    return lim, ST


def _seq_progressive_root(s, w, p, lim, ST, cnt='n'):
    """the progressive root: merkleize_progressive over the element roots"""
    if s.prog:
        # merkleize_progressive over the element roots (O.ptree's shape)
        w(f'def {p}_prr(+hl: Nat, +seg: U32, +dep: Nat, +s: Nat, +n: Nat, pair: {ST}) -> {ST}:')
        w('  (h, r) = pair')
        w('  (arr, dl) = r')
        w(f'  {p}_mj(hl, dl, {p}_mt(dep, 0n, True{{}}, hl, seg, O.pow2n(dep), s, n, (h, (arr, D.zero()))))')
        w(f'def {p}_ptr(f: Nat, inside: Bool, +hl: Nat, +seg: U32, +dep: Nat, +s: Nat, +n: Nat, st: {ST}) -> {ST}:')
        w('  match f:')
        w('    case 0n:')
        w('      (h, r) = st')
        w('      (arr, dl) = r')
        w('      (h, (arr, D.zero()))')
        w('    case 1n+g:')
        w('      match inside:')
        w('        case False{}:')
        w('          (h, r) = st')
        w('          (arr, dl) = r')
        w('          (h, (arr, D.zero()))')
        w('        case True{}:')
        w(f'          {p}_prr(hl, seg, dep, s, n,')
        w(f'            {p}_ptr(g, Nat.is_lt(Nat.add(s, O.pow2n(dep)), n), hl, seg, Nat.add(dep, 2n), Nat.add(s, O.pow2n(dep)), n, st))')
        tree_call = f'{p}_ptr(1n+U32.to_nat({cnt}), Nat.is_lt(0n, U32.to_nat({cnt})), hl, seg, 0n, 0n, U32.to_nat({cnt}), (h, (arr, D.zero())))'
    else:
        # The capacity 2^d is computed inside {p}_mt0 from the depth, never
        # written at the call site: the root laws compare the runtime's call
        # with their own, and two separately written copies of a closed 2^d
        # are compared digit by digit by the proof checker (it overflows past
        # about 2^14).
        # (The top level splits itself: an environment holding the closed 2^d
        # would be forced by the checker when two stuck roots are compared.)
        w(f'def {p}_mt0(+d: Nat, inside: Bool, +hl: Nat, +seg: U32, +n: Nat, st: {ST}) -> {ST}:')
        w('  match d:')
        w(f'    case 0n: {p}_mt(0n, 0n, inside, hl, seg, 1n, 0n, n, st)')
        w('    case 1n+q:')
        w('      match inside:')
        w('        case False{}:')
        w('          (h, r) = st')
        w('          (arr, dl) = r')
        w('          (h, (arr, D.zconst(1n+q)))')
        w('        case True{}:')
        w(f'          {p}_mt(q, 1n, Nat.is_lt(Nat.add(0n, O.pow2n(q)), n), hl, seg, O.pow2n(q), Nat.add(0n, O.pow2n(q)), n,')
        w(f'            {p}_mt(q, 0n, True{{}}, hl, seg, O.pow2n(q), 0n, n, st))')
        tree_call = (f'{p}_mt0({lim}n, Nat.is_lt(0n, U32.to_nat({cnt})), hl, seg, U32.to_nat({cnt}), '
                     f'(h, (arr, D.zero())))')
    return tree_call


def emit_seq(s, w):
    p, t, e = s.p, s.t, s.elem
    R, E = e.rep, e.p
    S = f'{p}_Seq'
    is_list = t.kind in ('list', 'plist')
    w(f'type {S} is Type:')
    w(f'  {S}{{items: Array<{R}>, n: U32}}')
    # storage: capacity for n elements (at least one slot)
    if e.data:
        w(f'def {p}_fill(+d: Nat) -> Array<{R}>: Array.new({R}, d, {E}_default())')
    else:
        w(f'def {p}_fill(+d: Nat) -> Array<{R}>:')
        w('  match d:')
        w(f'    case 0n: ALeaf{{{placeholder(e)}}}')
        w(f'    case 1n+q: ANode{{{p}_fill(q), {p}_fill(q)}}')
    w(f'def {p}_cap(+n: U32) -> Nat: B.words_depth(n)')
    count = t.size
    if is_list:
        w(f'def {p}_default() -> {S}: {S}{{{p}_fill(0n), 0}}')
    elif e.data:
        w(f'def {p}_default() -> {S}: {S}{{{p}_fill({p}_cap({count})), {count}}}')
    else:
        # A vector of elements with storage of their own holds `count` PRESENT elements, each the default of its type: an absent
        # slot (the empty box) has no bytes, so the serializer would write the offsets of elements it never writes
        # (docs/CRASH_HUNT.md CH-10).
        w(f'def {p}_dfill(+k: Nat, +i: U32, arr: Array<{R}>) -> Array<{R}>:')
        w('  match k:')
        w('    case 0n: arr')
        w(f'    case 1n+q: {p}_dfill(q, (i + 1 : U32), Array.set({R}, arr, i, {E}_default()))')
        w(f'def {p}_default() -> {S}: {S}{{{p}_dfill({count}n, 0, {p}_fill({p}_cap({count}))), {count}}}')
    # ---- read ----
    _seq_fixed_reader(w, p, e, R, E, S, is_list, count)
    # ---- size, put ----
    _seq_size_put(w, p, e, R, E, S)
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {S}) -> Array<U32> & {S}:')
    w('  match o:')
    w(f'    case {S}{{arr, +n}}: {p}_pt_nz(U32.is_eq(n, 0), pos, n, out, arr)')
    if e.fixed and not s.fixed:
        w(f'def {p}_ptn_fin(+n: U32, pair: Array<U32> & {S}) -> Array<U32> & ({S} & U32):')
        w('  (out, sq) = pair')
        w(f'  (out, (sq, (n * {e.fsize} : U32)))')
        w(f'def {p}_putn(out: Array<U32>, +pos: U32, o: {S}) -> Array<U32> & ({S} & U32):')
        w('  match o:')
        w(f'    case {S}{{arr, +n}}: {p}_ptn_fin(n, {p}_pt_nz(U32.is_eq(n, 0), pos, n, out, arr))')
    # ---- root: the recursive tree over the element roots, O.mtree's shape
    # (phase m = 0 computes a subtree, m = 1 holds the left sibling's root).
    lim, ST = _seq_root_tree(w, p, t, e, R, E)
    tree_call = _seq_progressive_root(s, w, p, lim, ST, 'm')
    mixed = 'd' if t.kind == 'vector' else 'O.mix_len(hl, d, n)'
    w(f'def {p}_rt_fin(+hl: Nat, +n: U32, pair: {ST}) -> B.Buf & ({S} & D.Digest):')
    w('  (h, r) = pair')
    w('  (arr, d) = r')
    w(f'  (h, ({S}{{arr, n}}, {mixed}))')
    # The tree is built over m = min(n, the storage) elements: a `{S}` is a public record, so n is a claim, and a root over the claimed
    # count would hash one default element per claimed index (docs/CRASH_HUNT.md R2-03). The length that is mixed in stays n.
    w(f'def {p}_rt_ct(+hl: Nat, +n: U32, h: B.Buf, +seg: U32, +m: U32, arr: Array<{R}>) -> B.Buf & ({S} & D.Digest): {p}_rt_fin(hl, n, {tree_call})')
    w(f'def {p}_rt_sz(+hl: Nat, +n: U32, h: B.Buf, +seg: U32, pair: Array<{R}> & U32) -> B.Buf & ({S} & D.Digest):')
    w('  (arr, +c) = pair')
    w(f'  {p}_rt_ct(hl, n, h, seg, O.pick(U32.is_le(n, c), n, c), arr)')
    w(f'def {p}_root(+hl: Nat, h: B.Buf, o: {S}, +seg: U32) -> B.Buf & ({S} & D.Digest):')
    w('  match o:')
    w(f'    case {S}{{arr, +n}}: {p}_rt_sz(hl, n, h, seg, Array.size({R}, arr))')


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
    take = f'Array.get({R}, arr, i)' if e.data else f'Array.swap({R}, arr, i, {placeholder(e)})'
    Pe = s.pelem.rep
    boxed = e.kind == 'box'

    def wrap(v):
        return f'{E}_wrap({v})' if boxed else v

    def unbox(v):
        return f'{E}_unbox({v})' if boxed else v
    w(f'type {C} is Type:')
    w(f'  {C}{{items: Array<{R}>, n: U32, d: Nat, nodes: Array<D.Digest>, lo: U32, hi: U32}}')
    w(f'type {TS} is Type:')
    w(f'  {TS}{{h: B.Buf, items: Array<{R}>, nodes: Array<D.Digest>}}')
    w(f'def {p}_dfill(+d: Nat) -> Array<D.Digest>: Array.new(D.Digest, d, D.zero())')
    # The tree has at most as many leaves as the array has slots: a depth beyond the array's (a claimed count, a hand-written depth)
    # is clamped to it, so the allocation is bounded by the storage (docs/CRASH_HUNT.md R2-03).
    w(f'def {p}_cache_fin(arr: Array<{R}>, +n: U32, +d: Nat) -> {C}:')
    w(f'  {C}{{arr, n, d, {p}_dfill(1n+d), 0, (O.pow2u(d) - 1 : U32)}}')
    w(f'def {p}_cache_sz(+n: U32, +d: Nat, pair: Array<{R}> & U32) -> {C}:')
    w('  (arr, +c) = pair')
    w(f'  {p}_cache_fin(arr, n, O.npick(O.cache_dok(Nat.is_lt(d, 32n), d, c), d, 0n))')
    w(f'def {p}_cache_at(arr: Array<{R}>, +n: U32, +d: Nat) -> {C}: {p}_cache_sz(n, d, Array.size({R}, arr))')
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
    cg = 'cget' if e.data else 'ctake'
    w(f'def {p}_{cg}(c: {C}, +i: U32) -> {C} & Maybe<&1, {Pe}>:')
    w('  match c:')
    w(f'    case {C}{{arr, +n, +d, nodes, +lo, +hi}}: {p}_cget_in(U32.is_lt(i, n), arr, n, d, nodes, lo, hi, i)')
    w(f'def {p}_cget_in(inside: Bool, arr: Array<{R}>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, +i: U32) -> {C} & Maybe<&1, {Pe}>:')
    w('  match inside:')
    w(f'    case True{{}}: {p}_ctook(n, d, nodes, lo, hi, {"" if e.data else "i, "}{take})')
    w(f'    case False{{}}: ({C}{{arr, n, d, nodes, lo, hi}}, None{{}})')
    w(f'def {p}_ctook(+n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, {"" if e.data else "+i: U32, "}pair: Array<{R}> & {R}) -> {C} & Maybe<&1, {Pe}>:')
    w(f'  (arr, {plus(e)}v) = pair')
    if e.data:
        w(f'  ({C}{{arr, n, d, nodes, lo, hi}}, Some{{{unbox("v")}}})')
    else:
        # the slot now holds the empty box, which the root reads as the default element: its leaf is dirty (docs/CRASH_HUNT.md R3-01)
        w(f'  ({C}{{arr, n, d, nodes, O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)}}, Some{{{unbox("v")}}})')
    w(f'def {p}_cset(c: {C}, +i: U32, v: {Pe}) -> {C} & Bool:')
    w('  match c:')
    w(f'    case {C}{{arr, +n, +d, nodes, +lo, +hi}}: {p}_cset_in(U32.is_lt(i, n), arr, n, d, nodes, lo, hi, i, v)')
    w(f'def {p}_cset_in(ok: Bool, arr: Array<{R}>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, +i: U32, v: {Pe}) -> {C} & Bool:')
    w('  match ok:')
    w(f'    case True{{}}: ({C}{{Array.set({R}, arr, i, {wrap("v")}), n, d, nodes,'
      ' O.pick(U32.is_le(lo, i), lo, i), O.pick(U32.is_le(i, hi), hi, i)}, True{})')
    w(f'    case False{{}}: ({C}{{arr, n, d, nodes, lo, hi}}, False{{}})')
    # the storage test of the uncached append (docs/CRASH_HUNT.md R3-02)
    w(f'def {p}_capp_sz(+n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, v: {Pe}, pair: Array<{R}> & U32) -> {C} & Bool:')
    w('  (arr, +sc) = pair')
    w(f'  {p}_capp_in(Bool.and({append_room("n", seq_count_bound(t, e))}, U32.is_le(n, sc)), arr, n, d, nodes, lo, hi, v)')
    w(f'def {p}_capp(c: {C}, v: {Pe}) -> {C} & Bool:')
    w('  match c:')
    w(f'    case {C}{{arr, +n, +d, nodes, +lo, +hi}}: {p}_capp_sz(n, d, nodes, lo, hi, v, Array.size({R}, arr))')
    w(f'def {p}_capp_in(ok: Bool, arr: Array<{R}>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, v: {Pe}) -> {C} & Bool:')
    w('  match ok:')
    w(f'    case True{{}}: ({p}_capp_fit(U32.is_lt(n, O.pow2u(d)), arr, n, d, nodes, lo, hi, v), True{{}})')
    w(f'    case False{{}}: ({C}{{arr, n, d, nodes, lo, hi}}, False{{}})')
    w(f'def {p}_capp_fit(fits: Bool, arr: Array<{R}>, +n: U32, +d: Nat, nodes: Array<D.Digest>, +lo: U32, +hi: U32, v: {Pe}) -> {C}:')
    w('  match fits:')
    w(f'    case True{{}}: {C}{{Array.set({R}, arr, n, {wrap("v")}), (n + 1 : U32), d, nodes,'
      ' O.pick(U32.is_le(lo, n), lo, n), O.pick(U32.is_le(n, hi), hi, n)}')
    w(f'    case False{{}}: {C}{{Array.set({R}, {p}_room(arr, n), n, {wrap("v")}), (n + 1 : U32), 1n+d,'
      f' {p}_dfill(2n+d), 0, (O.pow2u(1n+d) - 1 : U32)}}')
    # ---- the sweep: recompute the stale leaves, then their ancestors ----
    w(f'def {p}_ts_store(ts: {TS}, +k: U32, +dg: D.Digest) -> {TS}:')
    w('  match ts:')
    w(f'    case {TS}{{h, arr, nodes}}: {TS}{{h, arr, Array.set(D.Digest, nodes, k, dg)}}')
    if e.data:
        w(f'def {p}_leaf_fin(+k: U32, arr: Array<{R}>, nodes: Array<D.Digest>, pr: B.Buf & D.Digest) -> {TS}:')
        w('  (h, +dg) = pr')
        w(f'  {p}_ts_store({TS}{{h, arr, nodes}}, k, dg)')
        w(f'def {p}_leaf_go(+hl: Nat, +k: U32, +seg: U32, nodes: Array<D.Digest>, h: B.Buf, pr: Array<{R}> & {R}) -> {TS}:')
        w('  (arr, +v) = pr')
        w(f'  {p}_leaf_fin(k, arr, nodes, {E}_root(hl, h, v, (seg + 64 : U32)))')
        hash_args = 'k, seg, nodes, h, '
    else:
        w(f'def {p}_leaf_put(+k: U32, h: B.Buf, arr: Array<{R}>, nodes: Array<D.Digest>, +dg: D.Digest) -> {TS}:')
        w(f'  {p}_ts_store({TS}{{h, arr, nodes}}, k, dg)')
        w(f'def {p}_leaf_fin(+k: U32, +i: U32, arr: Array<{R}>, nodes: Array<D.Digest>, pr: B.Buf & ({R} & D.Digest)) -> {TS}:')
        w('  (h, r) = pr')
        w('  (v, dg) = r')
        w(f'  {p}_leaf_put(k, h, Array.set({R}, arr, i, v), nodes, dg)')
        w(f'def {p}_leaf_go(+hl: Nat, +k: U32, +i: U32, +seg: U32, nodes: Array<D.Digest>, h: B.Buf, pr: Array<{R}> & {R}) -> {TS}:')
        w('  (arr, v) = pr')
        w(f'  {p}_leaf_fin(k, i, arr, nodes, {E}_root(hl, h, v, (seg + 64 : U32)))')
        hash_args = 'k, i, seg, nodes, h, '
    w(f'def {p}_leaf_hash(+hl: Nat, +k: U32, +i: U32, +seg: U32, ts: {TS}) -> {TS}:')
    w('  match ts:')
    w(f'    case {TS}{{h, arr, nodes}}: {p}_leaf_go(hl, {hash_args}{take})')
    w(f'def {p}_leaf_step(+hl: Nat, inside: Bool, +k: U32, +i: U32, +seg: U32, ts: {TS}) -> {TS}:')
    w('  match inside:')
    w(f'    case True{{}}: {p}_leaf_hash(hl, k, i, seg, ts)')
    w(f'    case False{{}}: {p}_ts_store(ts, k, D.zero())')
    w(f'def {p}_leaves(+hl: Nat, +q: Nat, +i: U32, +n: U32, +seg: U32, +cap: U32, ts: {TS}) -> {TS}:')
    w('  match q:')
    w('    case 0n: ts')
    w('    case 1n+r:')
    w(f'      {p}_leaves(hl, r, (i + 1 : U32), n, seg, cap,'
      f' {p}_leaf_step(hl, U32.is_lt(i, n), (cap + i : U32), i, seg, ts))')
    # one internal node: the hash of its two children, both already up to date
    w(f'def {p}_node_fin(+hl: Nat, +j: U32, h: B.Buf, arr: Array<{R}>, +dl: D.Digest, pr: Array<D.Digest> & D.Digest) -> {TS}:')
    w('  (nodes, +dr) = pr')
    w(f'  {p}_ts_store({TS}{{h, arr, nodes}}, j, D.node(hl, dl, dr))')
    w(f'def {p}_node_go(+hl: Nat, +j: U32, h: B.Buf, arr: Array<{R}>, pr: Array<D.Digest> & D.Digest) -> {TS}:')
    w('  (nodes, +dl) = pr')
    w(f'  {p}_node_fin(hl, j, h, arr, dl, Array.get(D.Digest, nodes, (2 * j + 1 : U32)))')
    w(f'def {p}_node_step(+hl: Nat, +j: U32, ts: {TS}) -> {TS}:')
    w('  match ts:')
    w(f'    case {TS}{{h, arr, nodes}}: {p}_node_go(hl, j, h, arr, Array.get(D.Digest, nodes, (2 * j : U32)))')
    w(f'def {p}_level(+hl: Nat, +q: Nat, +j: U32, ts: {TS}) -> {TS}:')
    w('  match q:')
    w('    case 0n: ts')
    w(f'    case 1n+r: {p}_level(hl, r, (j + 1 : U32), {p}_node_step(hl, j, ts))')
    w(f'def {p}_levels(+hl: Nat, +L: Nat, +klo: U32, +khi: U32, ts: {TS}) -> {TS}:')
    w('  match L:')
    w('    case 0n: ts')
    w('    case 1n+q:')
    w(f'      {p}_levels(hl, q, U32.shrn(klo, 1n), U32.shrn(khi, 1n),'
      f' {p}_level(hl, U32.to_nat((U32.shrn(khi, 1n) - U32.shrn(klo, 1n) + 1 : U32)), U32.shrn(klo, 1n), ts))')
    w(f'def {p}_sweep(+hl: Nat, +d: Nat, +lo: U32, +hi: U32, +n: U32, +seg: U32, ts: {TS}) -> {TS}:')
    w(f'  {p}_levels(hl, d, (O.pow2u(d) + lo : U32), (O.pow2u(d) + hi : U32),'
      f' {p}_leaves(hl, U32.to_nat((hi - lo + 1 : U32)), lo, n, seg, O.pow2u(d), ts))')
    w(f'def {p}_sweep_pick(+hl: Nat, some: Bool, +d: Nat, +lo: U32, +hi: U32, +n: U32, +seg: U32, ts: {TS}) -> {TS}:')
    w('  match some:')
    w(f'    case True{{}}: {p}_sweep(hl, d, lo, hi, n, seg, ts)')
    w('    case False{}: ts')
    # the levels between the capacity and the list limit are zero subtrees
    w(f'def {p}_pad_go(+hl: Nat, +k: Nat, +lvl: U32, +r: D.Digest, pr: B.Buf & D.Digest) -> B.Buf & D.Digest:')
    w('  match k:')
    w('    case 0n:')
    w('      (h, +z) = pr')
    w('      (h, r)')
    w('    case 1n+q:')
    w('      (h, +z) = pr')
    w(f'      {p}_pad_go(hl, q, (lvl + 1 : U32), D.node(hl, r, z), (h, D.zconst(U32.to_nat((lvl + 1 : U32)))))')
    w(f'def {p}_croot_fin(+hl: Nat, +n: U32, +d: Nat, arr: Array<{R}>, nodes: Array<D.Digest>, pr: B.Buf & D.Digest) -> B.Buf & ({C} & D.Digest):')
    w('  (h, +r) = pr')
    # the dirty range after a root is [n, 0]: empty for n > 0 (for n = 0 it is
    # the single zero leaf 0). A later write at i < n widens it to [i, i] and an
    # append to [n, n], by the same min/max as from any range; the cache laws
    # reason about it without a closed 2^32 - 1 sentinel.
    w(f'  (h, ({C}{{arr, n, d, nodes, n, 0}}, O.mix_len(hl, r, n)))')
    w(f'def {p}_croot_pad(+hl: Nat, +n: U32, +d: Nat, arr: Array<{R}>, nodes: Array<D.Digest>, h: B.Buf, +r: D.Digest) -> B.Buf & ({C} & D.Digest):')
    w(f'  {p}_croot_fin(hl, n, d, arr, nodes,'
      f' {p}_pad_go(hl, Nat.sub({depth}n, d), O.nat_u32(d), r, (h, D.zconst(d))))')
    w(f'def {p}_croot_read(+hl: Nat, +n: U32, +d: Nat, h: B.Buf, arr: Array<{R}>, pr: Array<D.Digest> & D.Digest) -> B.Buf & ({C} & D.Digest):')
    w('  (nodes, +r) = pr')
    w(f'  {p}_croot_pad(hl, n, d, arr, nodes, h, r)')
    w(f'def {p}_croot_top(+hl: Nat, +n: U32, +d: Nat, ts: {TS}) -> B.Buf & ({C} & D.Digest):')
    w('  match ts:')
    w(f'    case {TS}{{h, arr, nodes}}: {p}_croot_read(hl, n, d, h, arr, Array.get(D.Digest, nodes, 1))')
    w(f'def {p}_cached_root(+hl: Nat, h: B.Buf, c: {C}, +seg: U32) -> B.Buf & ({C} & D.Digest):')
    w('  match c:')
    w(f'    case {C}{{arr, +n, +d, nodes, +lo, +hi}}:')
    w(f'      {p}_croot_top(hl, n, d, {p}_sweep_pick(hl, U32.is_le(lo, hi), d, lo, hi, n, seg, {TS}{{h, arr, nodes}}))')
    w('')


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
        if s.t.kind == 'pcontainer':
            emit_pcontainer_root(s, w, s.p, s.t.name, F, s.data)
        else:
            emit_fieldset_root(s, w, s.p, s.t.name, F, 'plain', s.data)
        emit_fields_access(w, s.p, s.t.name, F)
        return
    if s.t.kind == 'pcontainer':
        raise schema.SchemaError('a progressive container with more than %d active fields is not supported' % GROUP)
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
                w(f'  ({R}{{' + ', '.join(names) + f'}}, O.padd(acc, m))')
            else:
                nxt = var[j + 1]
                others2 = [f for k2, (f, fs) in enumerate(F) if k2 != nxt and (k2 not in var or var.index(k2) > j + 1)]
                done2 = [names[var[q]] for q in range(j + 1)]
                w(f'  {p}_sz{j + 1}({", ".join(others2 + done2)}, O.padd(acc, m), {F[nxt][1].p}_size({names[nxt]}))')
        first = var[0]
        others0 = [f for k2, f in enumerate(names) if k2 != first]
        w(f'def {p}_size(o: {R}) -> {R} & U32:')
        w('  match o:')
        args0 = others0 + [base, f'{F[first][1].p}_size({names[first]})']
        w(f'    case {pat}: {p}_sz0({", ".join(args0)})')
    else:
        w(f'def {p}_size(o: {R}) -> {R} & U32: (o, {base})')
    # ---- put ----
    # Each variable-size field is written once and reports how many bytes it
    # wrote, so its size is never computed by a separate traversal. The fields
    # are placed in order; a running cursor `cur` (the offset of the next
    # payload) goes into each variable field's writer, which also writes that
    # field's offset word and hands back the advanced cursor. So a variable
    # field costs one step of this chain - its result pair is taken apart and
    # the next field's writer is called in the same function - and nothing
    # but the cursor has to be remembered for the header: the fixed Data
    # fields are written in the last step, where the record is rebuilt.
    psteps = [('putv', i) for i in var] + [('put', i) for i in lin if i not in var]
    # The chain also decides validity (emit_valid): each linear field's checked
    # writer `putk` reports its size or flag with bit 31 set when the field is
    # invalid, the cursor keeps that bit, and the last step adds the Data
    # fields' checks. A fixed-size container threads a flag in the same slot.
    sized = bool(var) or mode == 'group'
    cur0 = 'voff' if mode == 'group' else (str(fixed_part) if sized else '0')
    entry = f'{p}_putn' if (sized and mode != 'group') else (f'{p}_put' if mode == 'group' else f'{p}_putk')
    rtype = f'Array<U32> & ({R} & U32)'
    dchk = [f'{fs.p}_valid({f})' for f, fs in F if fs.data and not trivial(fs)]

    def conj(xs):
        x = xs[-1]
        for y in reversed(xs[:-1]):
            x = f'Bool.and({y}, {x})'
        return x

    def fixed_writes(expr):
        for i, (f, fs) in enumerate(F):
            if fs.data:
                expr = f'{fs.p}_put({expr}, (pos + {hoff[i]} : U32), {f})'
        return expr

    def tail(cur):
        body = f'{R}{{' + ', '.join(names) + '}'
        if dchk:
            cur = f'({cur} .|. O.pz({conj(dchk)}) : U32)'
        return f'({fixed_writes("out")}, ({body}, {cur}))'

    def call(k, cur):
        kind_, i = psteps[k]
        fs = F[i][1]
        if kind_ == 'putv':
            return f'{putv_helper(fs, w)}(out, pos, {hoff[i]}, {cur}, {names[i]})'
        return f'{fs.p}_putk(out, (pos + {hoff[i]} : U32), {names[i]})'

    def head(name):
        if mode == 'group':
            w(f'def {name}(out: Array<U32>, +pos: U32, +voff: U32, o: {R}) -> {rtype}:')
        else:
            w(f'def {name}(out: Array<U32>, +pos: U32, o: {R}) -> {rtype}:')

    def wrapper():
        if mode == 'group':
            return
        if sized:
            w(f'def {p}_putk(out: Array<U32>, +pos: U32, o: {R}) -> {rtype}: {p}_putn(out, pos, o)')
        w(f'def {p}_put_drop(pair: Array<U32> & ({R} & U32)) -> Array<U32> & {R}:')
        w('  (out, r) = pair')
        w('  (v, m) = r')
        w(f'  {p}_put_drop_go(out, v, m)')
        w(f'def {p}_put_drop_go(out: Array<U32>, v: {R}, +m: U32) -> Array<U32> & {R}: (out, v)')
        src = f'{p}_putn' if sized else f'{p}_putk'
        w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {R}) -> Array<U32> & {R}: '
          f'{p}_put_drop({src}(out, pos, o))')

    if not psteps:
        head(entry)
        w('  match o:')
        w(f'    case {pat}: {tail(cur0)}')
        wrapper()
        return
    for kind_, i in psteps:
        if kind_ == 'putv':
            putv_helper(F[i][1], w)
    total_steps = len(psteps)
    for k in range(total_steps - 1, -1, -1):
        kind_, i = psteps[k]
        others = [f'{plus(fs)}{f}: {fs.rep}' for i2, (f, fs) in enumerate(F) if i2 != i]
        if kind_ == 'putv':
            # the cursor arrives in the pair, advanced past this field
            w(f'def {p}_pw{k}({", ".join(["+pos: U32"] + others)}, pair: Array<U32> & ({F[i][1].rep} & U32)) -> {rtype}:')
            w('  (out, r) = pair')
            w(f'  ({names[i]}, c) = r')
            cur = 'c'
        else:
            w(f'def {p}_pw{k}({", ".join(["+pos: U32", "+cur: U32"] + others)}, pair: Array<U32> & ({F[i][1].rep} & U32)) -> {rtype}:')
            w('  (out, r) = pair')
            w(f'  ({names[i]}, fl) = r')
            cur = '(cur .|. fl : U32)'
        if k == total_steps - 1:
            w(f'  {tail(cur)}')
        else:
            nk, ni = psteps[k + 1]
            held = [f for i2, f in enumerate(names) if i2 != ni]
            if nk == 'putv':
                w(f'  {p}_pw{k + 1}({", ".join(["pos"] + held)}, {call(k + 1, cur)})')
            else:
                w(f'  {p}_pw{k + 1}({", ".join(["pos", cur] + held)}, {call(k + 1, cur)})')
    held0 = [f for i2, f in enumerate(names) if i2 != psteps[0][1]]
    head(entry)
    w('  match o:')
    k0, i0 = psteps[0]
    if k0 == 'putv':
        w(f'    case {pat}: {p}_pw0({", ".join(["pos"] + held0)}, {call(0, cur0)})')
    else:
        w(f'    case {pat}: {p}_pw0({", ".join(["pos", cur0] + held0)}, {call(0, cur0)})')
    wrapper()

PUTV_EMITTED = set()


def putv_helper(fs, w):
    """`{shape}_putv(out, pos, hoff, cur, v)`: write the offset word `cur` at
    pos + hoff and the value's payload at pos + cur, and return the value with
    the cursor advanced past it. Emitted once per shape; the definitions are
    ordered before their users by `reorder`."""
    name = f'{fs.p}_putv'
    if name not in PUTV_EMITTED:
        PUTV_EMITTED.add(name)
        w(f'def {fs.p}_pvb(+cur: U32, pair: Array<U32> & ({fs.rep} & U32)) -> Array<U32> & ({fs.rep} & U32):')
        w('  (out, r) = pair')
        w('  (v, sz) = r')
        w('  (out, (v, O.padd(cur, sz)))')
        w(f'def {name}(out: Array<U32>, +pos: U32, +hoff: U32, +cur: U32, v: {fs.rep}) -> Array<U32> & ({fs.rep} & U32):')
        w(f'  {fs.p}_pvb(cur, {fs.p}_putk(O.w32(out, (pos + hoff : U32), cur), (pos + cur : U32), v))')
    return name


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


def emit_cunion(s, w):
    """A compatible union: a selector byte and the value of the selected
    option. The object is one constructor per option, so the selector cannot
    disagree with the payload. Its root mixes the selector into the option's
    root, which is the independent specification's rule for a union."""
    p, R = s.p, s.rep
    opts = s.options
    sels = list(s.t.selectors)
    n = len(opts)
    w(f'type {R} is Type:')
    for i, (_, os_) in enumerate(opts):
        w(f'  {R}_c{i}{{v: {os_.rep}}}')
    w(f'def {p}_default() -> {R}: {R}_c0{{{opts[0][1].p}_default()}}')

    # ---- validation: the selector picks the option, which validates the rest
    for i in range(n):
        o = opts[i][1]
        w(f'def {p}_ok{i}(c: Bool, +s: U32, buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool:')
        w('  match c:')
        w(f'    case True{{}}: {o.p}_ok(buf, (off + 1 : U32), (len - 1 : U32))')
        if i + 1 < n:
            w(f'    case False{{}}: {p}_ok{i + 1}(U32.is_eq(s, {sels[i + 1]}), s, buf, off, len)')
        else:
            w('    case False{}: (buf, False{})')
    w(f'def {p}_ok_sel(+off: U32, +len: U32, pair: B.Buf & U32) -> B.Buf & Bool:')
    w('  (buf, +s) = pair')
    w(f'  {p}_ok0(U32.is_eq(s, {sels[0]}), s, buf, off, len)')
    w(f'def {p}_ok_nz(nonempty: Bool, buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool:')
    w('  match nonempty:')
    w(f'    case True{{}}: {p}_ok_sel(off, len, O.rd_u8(buf, off))')
    w('    case False{}: (buf, False{})')
    w(f'def {p}_ok(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & Bool: {p}_ok_nz(U32.is_le(1, len), buf, off, len)')

    # ---- read (the window has already validated)
    for i, (_, o) in enumerate(opts):
        w(f'def {p}_rw{i}(pair: B.Buf & {o.rep}) -> B.Buf & {R}:')
        w(f'  (buf, {plus(o)}v) = pair')
        w(f'  (buf, {R}_c{i}{{v}})')
    for i in range(n):
        o = opts[i][1]
        w(f'def {p}_rd{i}(c: Bool, +s: U32, buf: B.Buf, +off: U32, +len: U32) -> B.Buf & {R}:')
        w('  match c:')
        w(f'    case True{{}}: {p}_rw{i}({o.p}_read(buf, (off + 1 : U32), (len - 1 : U32)))')
        if i + 1 < n:
            w(f'    case False{{}}: {p}_rd{i + 1}(U32.is_eq(s, {sels[i + 1]}), s, buf, off, len)')
        else:
            # unreachable for a validated window; the first option keeps the
            # function total without an error value in the decoded type
            w(f'    case False{{}}: {p}_rw0({opts[0][1].p}_read(buf, (off + 1 : U32), (len - 1 : U32)))')
    w(f'def {p}_rd_sel(+off: U32, +len: U32, pair: B.Buf & U32) -> B.Buf & {R}:')
    w('  (buf, +s) = pair')
    w(f'  {p}_rd0(U32.is_eq(s, {sels[0]}), s, buf, off, len)')
    w(f'def {p}_read(buf: B.Buf, +off: U32, +len: U32) -> B.Buf & {R}: {p}_rd_sel(off, len, O.rd_u8(buf, off))')

    # ---- size
    for i, (_, o) in enumerate(opts):
        if o.fixed:
            continue
        w(f'def {p}_sz{i}(pair: {o.rep} & U32) -> {R} & U32:')
        w('  (v, +m) = pair')
        w(f'  ({R}_c{i}{{v}}, (m + 1 : U32))')
    w(f'def {p}_size(o: {R}) -> {R} & U32:')
    w('  match o:')
    for i, (_, o) in enumerate(opts):
        if o.fixed:
            w(f'    case {R}_c{i}{{{plus(o)}v}}: ({R}_c{i}{{v}}, {o.fsize + 1})')
        else:
            w(f'    case {R}_c{i}{{v}}: {p}_sz{i}({o.p}_size(v))')

    # ---- put: the selector byte, then the option at pos + 1
    for i, (_, o) in enumerate(opts):
        if o.data:
            w(f'def {p}_pt{i}(+pos: U32, {plus(o)}v: {o.rep}, out: Array<U32>) -> Array<U32> & {R}:')
            w(f'  ({o.p}_put(O.w8(out, pos, {sels[i]}), (pos + 1 : U32), v), {R}_c{i}{{v}})')
        else:
            w(f'def {p}_pb{i}(pair: Array<U32> & {o.rep}) -> Array<U32> & {R}:')
            w('  (out, v) = pair')
            w(f'  (out, {R}_c{i}{{v}})')
            w(f'def {p}_pt{i}(+pos: U32, v: {o.rep}, out: Array<U32>) -> Array<U32> & {R}:')
            w(f'  {p}_pb{i}({o.p}_put(O.w8(out, pos, {sels[i]}), (pos + 1 : U32), v))')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {R}) -> Array<U32> & {R}:')
    w('  match o:')
    for i, (_, o) in enumerate(opts):
        w(f'    case {R}_c{i}{{{plus(o)}v}}: {p}_pt{i}(pos, v, out)')
    w(f'def {p}_putn_sz(out: Array<U32>, +pos: U32, pair: {R} & U32) -> Array<U32> & ({R} & U32):')
    w('  (o, +m) = pair')
    w(f'  {p}_putn_fin(m, {p}_put(out, pos, o))')
    w(f'def {p}_putn_fin(+m: U32, pair: Array<U32> & {R}) -> Array<U32> & ({R} & U32):')
    w('  (out, v) = pair')
    w('  (out, (v, m))')
    w(f'def {p}_putn(out: Array<U32>, +pos: U32, o: {R}) -> Array<U32> & ({R} & U32):')
    w(f'  {p}_putn_sz(out, pos, {p}_size(o))')

    # ---- root: mix_in_selector(root of the option, selector)
    for i, (_, o) in enumerate(opts):
        if o.data:
            w(f'def {p}_rt{i}(+hl: Nat, {plus(o)}v: {o.rep}, pair: B.Buf & D.Digest) -> B.Buf & ({R} & D.Digest):')
            w('  (h, d) = pair')
            w(f'  (h, ({R}_c{i}{{v}}, O.mix_len(hl, d, {sels[i]})))')
        else:
            w(f'def {p}_rt{i}(+hl: Nat, pair: B.Buf & ({o.rep} & D.Digest)) -> B.Buf & ({R} & D.Digest):')
            w('  (h, r) = pair')
            w('  (v, d) = r')
            w(f'  (h, ({R}_c{i}{{v}}, O.mix_len(hl, d, {sels[i]})))')
    w(f'def {p}_root(+hl: Nat, h: B.Buf, o: {R}, +seg: U32) -> B.Buf & ({R} & D.Digest):')
    w('  match o:')
    for i, (_, o) in enumerate(opts):
        if o.data:
            w(f'    case {R}_c{i}{{{plus(o)}v}}: {p}_rt{i}(hl, v, {o.p}_root(hl, h, v, seg))')
        else:
            w(f'    case {R}_c{i}{{v}}: {p}_rt{i}(hl, {o.p}_root(hl, h, v, seg))')

    # ---- force
    for i, (_, o) in enumerate(opts):
        if o.data:
            continue
        w(f'def {p}_fo{i}(pair: {o.rep} & U32) -> {R} & U32:')
        w('  (v, +x) = pair')
        w(f'  ({R}_c{i}{{v}}, x)')
    w(f'def {p}_force(o: {R}) -> {R} & U32:')
    w('  match o:')
    for i, (_, o) in enumerate(opts):
        if o.data:
            w(f'    case {R}_c{i}{{{plus(o)}v}}: ({R}_c{i}{{v}}, {o.p}_force(v))')
        else:
            w(f'    case {R}_c{i}{{v}}: {p}_fo{i}({o.p}_force(v))')

    # ---- selector access (the only observation the union itself offers)
    w(f'def {p}_selector(o: {R}) -> {R} & U32:')
    w('  match o:')
    for i, (_, o) in enumerate(opts):
        w(f'    case {R}_c{i}{{{plus(o)}v}}: ({R}_c{i}{{v}}, {sels[i]})')


def prog_segments(nchunks):
    """The progressive segments covering `nchunks` chunks: [(k, start, cap)].

    Segment k holds 4^k chunks starting at (4^k - 1)/3, so the chunks of a
    progressive tree fall into segments 0, 1, 2, ... and the segment roots are
    folded right to left. Exactly the layout src/merkle_fast.bend computes at
    run time; here every count is known when the code is generated, so the
    fold is emitted as straight-line hashing.
    """
    out, k = [], 0
    while True:
        start = ((1 << (2 * k)) - 1) // 3
        cap = 1 << (2 * k)
        out.append((k, start, cap))
        if start + cap >= nchunks:
            return out
        k += 1


def emit_root_chain(w, p, R, F, names, steps, rtype, bname, call, last):
    """The chain of <p>_rt<k> helpers that fold the field roots one at a time (each takes the fields not yet hashed and the digests so
    far), and <p>_root, which starts it. `last()` writes the body of the final helper; `bname(step)` names a step's digest and
    `call(step)` hashes the field (or zero level) the step stands for."""
    for k in range(len(steps) - 1, -1, -1):
        st = steps[k]
        params = []
        for i2, (f, fs) in enumerate(F):
            if st[0] == 'f' and i2 == st[1] and not fs.data:
                continue
            params.append(f'{plus(fs)}{f}: {fs.rep}')
        params += [f'{bname(x)}: D.Digest' for x in steps[:k]]
        if st[0] == 'f' and not F[st[1]][1].data:
            w(f'def {p}_rt{k}(' + ', '.join(['+hl: Nat', '+seg: U32'] + params + [f'pair: B.Buf & ({F[st[1]][1].rep} & D.Digest)']) + f') -> {rtype}:')
            w('  (h, r) = pair')
            w(f'  ({names[st[1]]}, {bname(st)}) = r')
        else:
            w(f'def {p}_rt{k}(' + ', '.join(['+hl: Nat', '+seg: U32'] + params + ['pair: B.Buf & D.Digest']) + f') -> {rtype}:')
            w(f'  (h, {bname(st)}) = pair')
        if k == len(steps) - 1:
            last()
            continue
        nst = steps[k + 1]
        held = [f for i2, (f, fs) in enumerate(F) if not (nst[0] == 'f' and i2 == nst[1] and not fs.data)]
        done = [bname(x) for x in steps[:k + 1]]
        w(f'  {p}_rt{k + 1}(' + ', '.join(['hl', 'seg'] + held + done + [call(nst)]) + ')')
    pat = f'{R}{{' + ', '.join(f'{plus(fs)}{f}' for f, fs in F) + '}'
    held0 = [f for i2, (f, fs) in enumerate(F) if not (i2 == 0 and not fs.data)]
    w(f'def {p}_root(+hl: Nat, h: B.Buf, o: {R}, +seg: U32) -> {rtype}:')
    w('  match o:')
    w(f'    case {pat}: {p}_rt0(hl, seg, {", ".join(held0)}{", " if held0 else ""}{call(steps[0])})')

def emit_pcontainer_root(s, w, p, R, F, data):
    """Root of a progressive container: its fields sit at their active
    positions of a progressive chunk tree, every inactive position is a zero
    chunk, and the active bit vector is mixed in at the end, which is the
    independent specification's rule for a progressive container."""
    names = [f for f, _ in F]
    active = list(s.t.active)
    L = len(active)
    mask = sum(1 << i for i, b in enumerate(active) if b)
    slots, j = [], 0
    for b in active:
        if b:
            slots.append(('f', j))
            j += 1
        else:
            slots.append(('z', 0))
    zneed = set()

    def build():
        """The root expression, as a node: ('Z', lv) or ('E', text)."""
        acc = ('E', 'D.zero()')
        segs = prog_segments(L)
        for k, start, cap in reversed(segs):
            level = []
            for i in range(cap):
                idx = start + i
                if idx < L and slots[idx][0] == 'f':
                    level.append(('E', f'd_{names[slots[idx][1]]}'))
                else:
                    level.append(('Z', 0))
            lv = 0
            while len(level) > 1:
                nxt = []
                for i in range(0, len(level), 2):
                    a, b = level[i], level[i + 1]
                    if a[0] == 'Z' and b[0] == 'Z':
                        nxt.append(('Z', lv + 1))
                    else:
                        nxt.append(('E', f'D.node(hl, {concrete(a)}, {concrete(b)})'))
                level = nxt
                lv += 1
            acc = ('E', f'D.node(hl, {concrete(acc)}, {concrete(level[0])})')
        return concrete(acc)

    def concrete(node):
        if node[0] == 'E':
            return node[1]
        if node[1] == 0:
            return 'D.zero()'
        zneed.add(node[1])
        return f'z{node[1]}'

    body = build()
    steps = [('f', i) for i in range(len(F))] + [('z', lv) for lv in sorted(zneed)]
    rtype = 'B.Buf & D.Digest' if data else f'B.Buf & ({R} & D.Digest)'

    def bname(st):
        return f'd_{names[st[1]]}' if st[0] == 'f' else f'z{st[1]}'

    def call(st, hexpr='h'):
        if st[0] == 'z':
            return f'({hexpr}, D.zconst({st[1]}n))'
        fs = F[st[1]][1]
        return f'{fs.p}_root(hl, {hexpr}, {names[st[1]]}, seg)'

    finp = ['+hl: Nat'] + [f'+{bname(x)}: D.Digest' for x in steps] + ['h: B.Buf'] + [f'{plus(fs)}{f}: {fs.rep}' for f, fs in F]
    w(f'def {p}_fin(' + ', '.join(finp) + f') -> {rtype}:')
    if data:
        w(f'  (h, O.mix_len(hl, {body}, {mask}))')
    else:
        w(f'  (h, ({R}{{' + ', '.join(names) + f'}}, O.mix_len(hl, {body}, {mask})))')
    def last():
        # The final combination uses each zero digest several times, so it
        # lives in one helper whose digest parameters are duplicable.
        w(f'  {p}_fin(' + ', '.join(['hl'] + [bname(x) for x in steps] + ['h'] + names) + ')')

    emit_root_chain(w, p, R, F, names, steps, rtype, bname, call, last)


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
            return f'({hexpr}, D.zconst({st[1]}n))'
        fs = F[st[1]][1]
        return f'{fs.p}_root(hl, {hexpr}, {names[st[1]]}, seg)'

    def combine():
        level = [f'd_{f}' for f in names]
        lv = 0
        while (1 << lv) < width:
            if len(level) % 2:
                level.append('D.zero()' if lv == 0 else f'z{lv}')
            level = [f'D.node(hl, {level[i]}, {level[i + 1]})' for i in range(0, len(level), 2)]
            lv += 1
        return level[0]

    def last():
        if data:
            w(f'  (h, {combine()})')
        else:
            w(f'  (h, ({R}{{' + ', '.join(names) + f'}}, {combine()}))')

    emit_root_chain(w, p, R, F, names, steps, rtype, bname, call, last)


def emit_group_force(g, w):
    emit_force_fields(w, g.p, g.rep, g.fields, g.data)
    emit_valid_fields(TAIL.append, g.p, g.rep, g.fields, g.data)
    emit_dump_fields(w, g.p, g.rep, g.fields)


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
                w(f'  ({R}{{' + ', '.join(gn) + '}, O.padd(acc, m))')
            else:
                nx = lin[j + 1]
                others2 = [f'g{g2.k}' for g2 in groups if g2.k != nx.k and (g2.data or lin.index(g2) > j + 1)]
                done2 = [f'g{lin[q].k}' for q in range(j + 1)]
                w(f'  {p}_sz{j + 1}({", ".join(others2 + done2)}, O.padd(acc, m), {nx.p}_size(g{nx.k}))')
        others0 = [x for x, g in zip(gn, groups) if g.k != lin[0].k]
        w(f'def {p}_size(o: {R}) -> {R} & U32:')
        w('  match o:')
        w(f'    case {pat}: {p}_sz0({", ".join(others0)}, {fixed_part}, {lin[0].p}_size(g{lin[0].k}))')
    else:
        w(f'def {p}_size(o: {R}) -> {R} & U32: (o, {fixed_part})')
    # put: groups in order; Data groups are pure writes, linear ones return
    # (out, (group, voff)); the last group's running offset is the whole
    # container's size, so a wide container reports it the same way a plain one
    # does and no caller has to size it again.
    variable = not s.fixed
    # the running offset keeps bit 31 of any invalid group (emit_fieldset);
    # the Data groups' checks are added at the end. A fixed-size wide
    # container reports that bit alone, as its checked writer `putk`.
    rtype = f'Array<U32> & ({R} & U32)'
    gchk = [f'{g.p}_valid(g{g.k})' for g in groups if g.data and not trivial(g)]

    def done(expr, voff):
        rec = f'{R}{{' + ', '.join(gn) + '}'
        if gchk:
            x = gchk[-1]
            for y in reversed(gchk[:-1]):
                x = f'Bool.and({y}, {x})'
            voff = f'({voff} .|. O.pz({x}) : U32)'
        if not variable:
            voff = f'({voff} .&. 4294967295 : U32)'
        return f'({expr}, ({rec}, {voff}))'

    for j in range(len(lin) - 1, -1, -1):
        g = lin[j]
        params = ['+pos: U32'] + [f'{plus(g2)}g{g2.k}: {g2.rep}' for g2 in groups if g2.k != g.k]
        nxt = lin[j + 1] if j + 1 < len(lin) else None
        expr = 'out'
        for g2 in groups:
            if g2.data and g2.k > g.k and (nxt is None or g2.k < nxt.k):
                expr = f'{g2.p}_put({expr}, pos, voff, g{g2.k})'
        if nxt is None:
            body = done(expr, 'voff')
        else:
            held = [f'g{g2.k}' for g2 in groups if g2.k != nxt.k]
            body = f'{p}_pw{j + 1}(pos, {", ".join(held)}, {nxt.p}_put({expr}, pos, voff, g{nxt.k}))'
        allp = ['+pos: U32'] + [f'{plus(g2)}g{g2.k}: {g2.rep}' for g2 in groups] + ['+voff: U32', 'out: Array<U32>']
        w(f'def {p}_pw{j}v({", ".join(allp)}) -> {rtype}:')
        w(f'  {body}')
        w(f'def {p}_pw{j}({", ".join(params)}, pair: Array<U32> & ({g.rep} & U32)) -> {rtype}:')
        w('  (out, r) = pair')
        w(f'  (g{g.k}, vo) = r')
        w(f'  {p}_pw{j}v(pos, {", ".join(["g%d" % g2.k for g2 in groups])}, vo, out)')
    w(f'def {p}_{"putn" if variable else "putk"}(out: Array<U32>, +pos: U32, o: {R}) -> {rtype}:')
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
        w(f'    case {pat}: {done(expr, str(fixed_part))}')
    if variable:
        w(f'def {p}_putk(out: Array<U32>, +pos: U32, o: {R}) -> {rtype}: {p}_putn(out, pos, o)')
    w(f'def {p}_put_drop_go(out: Array<U32>, v: {R}, +m: U32) -> Array<U32> & {R}: (out, v)')
    w(f'def {p}_put_drop(pair: Array<U32> & ({R} & U32)) -> Array<U32> & {R}:')
    w('  (out, r) = pair')
    w('  (v, m) = r')
    w(f'  {p}_put_drop_go(out, v, m)')
    w(f'def {p}_put(out: Array<U32>, +pos: U32, o: {R}) -> Array<U32> & {R}: '
      f'{p}_put_drop({p}_{"putn" if variable else "putk"}(out, pos, o))')
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
            return f'(h, D.zconst({st[1]}n))'
        return f'{groups[st[1]].p}_root(hl, h, g{st[1]}, seg)'

    def combine():
        level = [f'r{g.k}' for g in groups]
        lv = 0
        while (1 << lv) < width:
            if len(level) % 2:
                level.append(f'z{3 + lv}')
            level = [f'D.node(hl, {level[i]}, {level[i + 1]})' for i in range(0, len(level), 2)]
            lv += 1
        return level[0]

    rt = 'B.Buf & D.Digest' if data else f'B.Buf & ({R} & D.Digest)'
    for k in range(len(steps) - 1, -1, -1):
        st = steps[k]
        params = [f'{plus(g)}g{g.k}: {g.rep}' for g in groups if not (st[0] == 'g' and g.k == st[1] and not g.data)]
        params += [f'{rb(x)}: D.Digest' for x in steps[:k]]
        if st[0] == 'g' and not groups[st[1]].data:
            w(f'def {p}_rt{k}(+hl: Nat, +seg: U32, {", ".join(params)}, pair: B.Buf & ({groups[st[1]].rep} & D.Digest)) -> {rt}:')
            w('  (h, r) = pair')
            w(f'  (g{st[1]}, {rb(st)}) = r')
        else:
            w(f'def {p}_rt{k}(+hl: Nat, +seg: U32, {", ".join(params)}, pair: B.Buf & D.Digest) -> {rt}:')
            w(f'  (h, {rb(st)}) = pair')
        if k == len(steps) - 1:
            w(f'  (h, {combine()})' if data else f'  (h, ({R}{{' + ', '.join(gn) + f'}}, {combine()}))')
            continue
        nst = steps[k + 1]
        held = [f'g{g.k}' for g in groups if not (nst[0] == 'g' and g.k == nst[1] and not g.data)]
        done = [rb(x) for x in steps[:k + 1]]
        w(f'  {p}_rt{k + 1}(hl, seg, {", ".join(held + done)}, {rcall(nst)})')
    held0 = [f'g{g.k}' for g in groups if not (g.k == 0 and not g.data)]
    w(f'def {p}_root(+hl: Nat, h: B.Buf, o: {R}, +seg: U32) -> {rt}:')
    w('  match o:')
    w(f'    case {pat}: {p}_rt0(hl, seg, {", ".join(held0)}, {rcall(steps[0])})')


# ---------------------------------------------------------------------------
# Public per-name API.

def cap_depth(nbytes):
    """The depth O.out_new would compute for this many bytes: the smallest d
    with 2^d words covering nbytes, exactly B.capacity's value."""
    words = (nbytes + 3) // 4
    d = 0
    while (1 << d) < max(1, words):
        d += 1
    return d


def size_bounds(t):
    """(min, max) encoded bytes of every value of schema type t; max is None
    when the type admits arbitrarily large values (progressive forms)."""
    k = t.kind
    if t.fixed():
        n = t.fixed_size()
        return n, n
    if k == 'bytelist':
        return 0, t.size
    if k == 'bitlist':
        return 1, t.size // 8 + 1
    if k in ('vector', 'list'):
        lo, hi = size_bounds(t.elem)
        count_lo = t.size if k == 'vector' else 0
        per = 0 if t.elem.fixed() else 4
        return count_lo * (lo + per), None if hi is None else t.size * (hi + per)
    if k == 'container':
        lo = hi = 0
        for _, ft in t.fields:
            a, b = size_bounds(ft)
            extra = 0 if ft.fixed() else 4
            lo += a + extra
            hi = None if (hi is None or b is None) else hi + b + extra
        return lo, hi
    if k == 'cunion':
        opts = [size_bounds(ft) if ft is not None else (0, 0) for _, ft in t.fields]
        return 1 + min(a for a, _ in opts), (None if any(b is None for _, b in opts) else 1 + max(b for _, b in opts))
    return 0, None


# An encode whose output depth is known from the type alone skips the size
# traversal: the output is allocated at that literal depth and the writer's
# own byte count is the length. That is exact when every value's encoding has
# the same depth. A range straddling one power of two is accepted only when it
# is narrow (within 1/8 of its minimum) and small (at most 4096 words), so the
# allocation is at most one power of two larger than the size pass would pick
# and only for the few values just under the boundary.
LITERAL_ENCODE_MAX_DEPTH = 20
LITERAL_STRADDLE_MAX_DEPTH = 12


def literal_depth(t):
    lo, hi = size_bounds(t)
    if hi is None:
        return None
    dl, dh = cap_depth(lo), cap_depth(hi)
    if dh == dl and dh <= LITERAL_ENCODE_MAX_DEPTH:
        return dh
    if dh == dl + 1 and dh <= LITERAL_STRADDLE_MAX_DEPTH and 8 * hi <= 9 * lo:
        return dh
    return None


def emit_api(g, name, s, w):
    R = s.rep
    p = s.p
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
    # `_decode_in` is the decoder of a window that lies inside the buffer; `_decode` refuses (None) a window that does not
    # (size > B.size(buf), docs/CRASH_HUNT.md CH-06). The decode laws state their results on `_decode_in` or, with the premise
    # `size <= B.size(buf)`, on `_decode`.
    w(f'def {name}_decode_in(buf: B.Buf, +size: U32) -> B.Buf & Maybe<&1, {R}>:')
    w(f'  {name}_built(size, {p}_ok(buf, 0, size))')
    w(f'def {name}_dwgo(ok: Bool, buf: B.Buf, +size: U32) -> B.Buf & Maybe<&1, {R}>:')
    w('  match ok:')
    w(f'    case True{{}}: {name}_decode_in(buf, size)')
    w('    case False{}: (buf, None{})')
    w(f'def {name}_dwin(+size: U32, pair: B.Buf & U32) -> B.Buf & Maybe<&1, {R}>:')
    w('  (buf, +n) = pair')
    w(f'  {name}_dwgo(U32.is_le(size, n), buf, size)')
    w(f'def {name}_decode(buf: B.Buf, +size: U32) -> B.Buf & Maybe<&1, {R}>: {name}_dwin(size, B.size(buf))')
    w(f'def {name}_build(buf: B.Buf, +size: U32) -> B.Buf & {R}: {p}_read(buf, 0, size)')
    # The checked entry (docs/CRASH_HUNT.md CH-05, CH-06, R2-04): `_decode` takes the window size from the caller and trusts that it
    # lies inside the buffer and below the 2^31 byte limit of every size in this library; the checked one verifies both, and that
    # the window is inside the words the buffer's array holds (`B.Buf` is a public constructor: its size is a claim), and answers
    # None otherwise. For every window it accepts, it is `_decode`.
    w(f'def {name}_dgo(ok: Bool, buf: B.Buf, +size: U32) -> B.Buf & Maybe<&1, {R}>:')
    w('  match ok:')
    w(f'    case True{{}}: {name}_decode(buf, size)')
    w('    case False{}: (buf, None{})')
    w(f'def {name}_dchw(+size: U32, +n: U32, pair: B.Buf & U32) -> B.Buf & Maybe<&1, {R}>:')
    w('  (buf, +c) = pair')
    w(f'  {name}_dgo(Bool.and(Bool.and(U32.is_le(size, n), U32.is_le(size, 4294967264)), U32.is_le(U32.shrn((size + 3 : U32), 2n), c)), buf, size)')
    w(f'def {name}_dchk(+size: U32, pair: B.Buf & U32) -> B.Buf & Maybe<&1, {R}>:')
    w('  (buf, +n) = pair')
    w(f'  {name}_dchw(size, n, B.stored(buf))')
    w(f'def {name}_decode_checked(buf: B.Buf, +size: U32) -> B.Buf & Maybe<&1, {R}>: {name}_dchk(size, B.size(buf))')
    # encode
    if s.data:
        # the output of a fixed-size value has a size known here, so the
        # allocation takes the depth directly instead of computing it
        w(f'def {name}_encode(+o: {R}) -> B.Buf: '
          f'O.out_done({s.fsize}, {p}_put(O.out_at({cap_depth(s.fsize)}n), 0, o))')
        w(f'def {name}_hash_tree_root(h: B.Buf, +o: {R}) -> B.Buf & D.Digest: {p}_root(64n, h, o, 0)')
    else:
        # A non-recursive record is laid out inline, so every function
        # boundary that carries one copies its words. The encode path
        # therefore goes straight to the size-reporting writer instead of
        # through `_put` and its size-dropping wrapper: two fewer boundaries
        # carrying the whole value.
        lit = literal_depth(s.t)
        # The stages are emitted twice: `encode` returns the buffer, the
        # serialize path (x = 's') returns it inside Some, entering the first
        # stage straight from the validity decision - no extra boundary.
        wmain = w
        for x, Bt, wrap in (('', 'B.Buf', lambda e: e), ('s', 'O.Encoded', lambda e: f'O.encoded({e})')):
            w = wmain if x == '' else TAIL.append
            if lit is not None and not s.fixed:
                w(f'def {name}_{x}enc_out(out: Array<U32>, o: {R}, +m: U32) -> {R} & {Bt}:')
                if x == '':
                    w('  (o, O.out_done((m .&. 2147483647 : U32), out))')
                else:
                    # the writer's length carries bit 31 when the value is invalid
                    w('  (o, O.ser_done(O.is_poisoned(m), m, out))')
                w(f'def {name}_{x}enc_put(pair: Array<U32> & ({R} & U32)) -> {R} & {Bt}:')
                w('  (out, r) = pair')
                w('  (o, m) = r')
                w(f'  {name}_{x}enc_out(out, o, m)')
                first = f'{name}_{x}enc_put({p}_{"putk" if x else "putn"}(O.out_at({lit}n), 0, o))'
            elif lit is not None and x == '':
                w(f'def {name}_{x}enc_out(pair: Array<U32> & {R}) -> {R} & {Bt}:')
                w('  (out, o) = pair')
                w(f'  (o, {wrap(f"O.out_done({s.fsize}, out)")})')
                first = f'{name}_{x}enc_out({p}_put(O.out_at({lit}n), 0, o))'
            elif lit is not None:
                w(f'def {name}_{x}enc_out(pair: Array<U32> & ({R} & U32)) -> {R} & {Bt}:')
                w('  (out, r) = pair')
                w('  (o, fl) = r')
                w(f'  (o, O.ser_done(O.is_poisoned(fl), {s.fsize}, out))')
                first = f'{name}_{x}enc_out({p}_putk(O.out_at({lit}n), 0, o))'
            elif not s.fixed:
                w(f'def {name}_{x}enc_out(+n: U32, out: Array<U32>, o: {R}, +m: U32) -> {R} & {Bt}:')
                if x == '':
                    w('  (o, O.out_done(n, out))')
                else:
                    w('  (o, O.ser_done(O.is_poisoned(m), n, out))')
                w(f'def {name}_{x}enc_put(+n: U32, pair: Array<U32> & ({R} & U32)) -> {R} & {Bt}:')
                w('  (out, r) = pair')
                w('  (o, m) = r')
                w(f'  {name}_{x}enc_out(n, out, o, m)')
                if x == '':
                    w(f'def {name}_{x}enc_sized(pair: {R} & U32) -> {R} & {Bt}:')
                    w('  (o, +n) = pair')
                    w(f'  {name}_{x}enc_put(n, {p}_putn(O.out_new(n), 0, o))')
                else:
                    # a size with bit 31 (storage that cannot hold the value)
                    # is refused before anything is allocated
                    w(f'def {name}_{x}enc_go(bad: Bool, +n: U32, o: {R}) -> {R} & {Bt}:')
                    w('  match bad:')
                    w(f'    case True{{}}: (o, O.refused())')
                    w(f'    case False{{}}: {name}_{x}enc_put(n, {p}_putk(O.out_new(n), 0, o))')
                    w(f'def {name}_{x}enc_sized(pair: {R} & U32) -> {R} & {Bt}:')
                    w('  (o, +n) = pair')
                    w(f'  {name}_{x}enc_go(O.is_poisoned(n), n, o)')
                first = f'{name}_{x}enc_sized({p}_size(o))'
            elif x == '':
                w(f'def {name}_{x}enc_out(+n: U32, pair: Array<U32> & {R}) -> {R} & {Bt}:')
                w('  (out, o) = pair')
                w(f'  (o, {wrap("O.out_done(n, out)")})')
                w(f'def {name}_{x}enc_sized(pair: {R} & U32) -> {R} & {Bt}:')
                w('  (o, +n) = pair')
                w(f'  {name}_{x}enc_out(n, {p}_put(O.out_new(n), 0, o))')
                first = f'{name}_{x}enc_sized({p}_size(o))'
            else:
                w(f'def {name}_{x}enc_out(+n: U32, pair: Array<U32> & ({R} & U32)) -> {R} & {Bt}:')
                w('  (out, r) = pair')
                w('  (o, fl) = r')
                w('  (o, O.ser_done(O.is_poisoned(fl), n, out))')
                w(f'def {name}_{x}enc_sized(pair: {R} & U32) -> {R} & {Bt}:')
                w('  (o, +n) = pair')
                w(f'  {name}_{x}enc_out(n, {p}_putk(O.out_new(n), 0, o))')
                first = f'{name}_{x}enc_sized({p}_size(o))'
            if x == '':
                w(f'def {name}_encode(o: {R}) -> {R} & B.Buf: {first}')
            else:
                sfirst = first
        w = wmain
        w(f'def {name}_hash_tree_root(h: B.Buf, o: {R}) -> B.Buf & ({R} & D.Digest): {p}_root(64n, h, o, 0)')
    wmain2 = w
    w = TAIL.append
    # serialize: the public encoder. It encodes a valid value and refuses an
    # invalid representable one (see emit_valid) instead of encoding it.
    if s.data:
        w(f'def {name}_ser_pick(ok: Bool, +o: {R}) -> O.Encoded:')
        w('  match ok:')
        w(f'    case True{{}}: O.encoded({name}_encode(o))')
        w('    case False{}: O.refused()')
        w(f'def {name}_serialize(+o: {R}) -> O.Encoded: {name}_ser_pick({p}_valid(o), o)')
    else:
        # the checked writers decide validity as they write; a sized value
        # whose size pass finds storage unable to hold it is refused first
        w(f'def {name}_serialize(o: {R}) -> {R} & O.Encoded: {sfirst}')
    w('')
    w = wmain2
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
        # sorted: set order depends on the per-process string hash seed, and the
        # emitted order must not (deterministic regeneration)
        for ref in sorted(set(re.findall(r'\b([A-Za-z][A-Za-z0-9_]*)\(', body + sig)) | set(re.findall(r'\b([A-Z][A-Za-z0-9_]*)\{', body + sig))):
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


GROUP_TYPES = 12          # named types per generated program. Twelve is not
                          # arbitrary: the platform C compiler's register
                          # allocator crashes ("live register clobbered by
                          # inserted prologue instructions") on programs that
                          # hold a very wide container with few other names -
                          # BeaconState alone, or in a group of six, does not
                          # build, while the group of twelve does. Smaller
                          # groups are not automatically safer.
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
        return ['set', 'append'] if fs.t.kind in ('list', 'plist') else ['set']
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


def emit_group(g, names, ns, k, with_fuzz=False, prefix='g', module='fulu_obj'):
    """types/fulu_obj_g{k}.bend: a sum over this group's objects and the
    operations dispatched by the name's global index (the frozen schema
    order). The benchmark and check programs use one group each."""
    L = []
    w = L.append
    w('import Base')
    w('import ../src/buffer.bend as B')
    w('import ../src/digest.bend as D')
    w('import ../src/obj.bend as O')
    w(f'import ./{module}.bend as T')
    w('')
    w(f'# GENERATED by typed_object_runtime (codegen). Do not edit. {"Fuzz group" if with_fuzz else "Group"} {k}: '
      + ', '.join(n for n, _ in ns) + '.')
    # The measured program's dispatch sum. The native backend lays a
    # non-recursive ADT out inline, sized by its widest constructor, so a
    # group holding one very wide record made every other name in the group
    # pay that width on each decode (BlobIdentifier decoded in 165 ns next to
    # BeaconState, against 45 ns for the identically shaped Checkpoint in
    # another group). The unreachable recursive constructor makes the type
    # recursive, so the backend boxes it and each value costs only its own
    # payload. It is never constructed and never matched on a real value.
    w('type Any is Type:')
    for n, i in ns:
        w(f'  A_{n}{{v: {qual(g.shape(names[n]).rep)}}}')
    w('  A_boxed{v: Any}')
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
            w(f'def enc_{n}(+v: {R}) -> Any & B.Buf: (A_{n}{{v}}, O.ser_out(T.{n}_serialize(v)))')
            w(f'def root_{n}(+v: {R}, pair: B.Buf & D.Digest) -> B.Buf & (Any & D.Digest):')
            w('  (h, d) = pair')
            w(f'  (h, (A_{n}{{v}}, d))')
            w(f'def force_{n}(+v: {R}) -> Any & U32: (A_{n}{{v}}, T.{sh.p}_force(v))')
            enc.append(f'    case A_{n}{{+v}}: enc_{n}(v)')
            rt.append(f'    case A_{n}{{+v}}: root_{n}(v, T.{n}_hash_tree_root(h, v))')
            fo.append(f'    case A_{n}{{+v}}: force_{n}(v)')
        else:
            w(f'def enc_{n}(pair: {R} & O.Encoded) -> Any & B.Buf:')
            w('  (v, out) = pair')
            w(f'  (A_{n}{{v}}, O.ser_out(out))')
            w(f'def root_{n}(pair: B.Buf & ({R} & D.Digest)) -> B.Buf & (Any & D.Digest):')
            w('  (h, r) = pair')
            w('  (v, d) = r')
            w(f'  (h, (A_{n}{{v}}, d))')
            w(f'def force_{n}(pair: {R} & U32) -> Any & U32:')
            w('  (v, +x) = pair')
            w(f'  (A_{n}{{v}}, x)')
            enc.append(f'    case A_{n}{{v}}: enc_{n}(T.{n}_serialize(v))')
            rt.append(f'    case A_{n}{{v}}: root_{n}(T.{n}_hash_tree_root(h, v))')
            fo.append(f'    case A_{n}{{v}}: force_{n}(T.{sh.p}_force(v))')
    w('def enc_boxed(pair: Any & B.Buf) -> Any & B.Buf:')
    w('  (v, out) = pair')
    w('  (A_boxed{v}, out)')
    w('def root_boxed(pair: B.Buf & (Any & D.Digest)) -> B.Buf & (Any & D.Digest):')
    w('  (h, r) = pair')
    w('  (v, d) = r')
    w('  (h, (A_boxed{v}, d))')
    w('def force_boxed(pair: Any & U32) -> Any & U32:')
    w('  (v, +x) = pair')
    w('  (A_boxed{v}, x)')
    w('def encode(a: Any) -> Any & B.Buf:')
    w('  match a:')
    L.extend(enc)
    w('    case A_boxed{v}: enc_boxed(encode(v))')
    w('def root(h: B.Buf, a: Any) -> B.Buf & (Any & D.Digest):')
    w('  match a:')
    L.extend(rt)
    w('    case A_boxed{v}: root_boxed(root(h, v))')
    w('def force(a: Any) -> Any & U32:')
    w('  match a:')
    L.extend(fo)
    w('    case A_boxed{v}: force_boxed(force(v))')
    # the structural value dump for the conformance runner (consumes the object)
    w('def dump(a: Any, t: +List<U32>) -> +List<U32>:')
    w('  match a:')
    for n, i in ns:
        sh = g.shape(names[n])
        w(f'    case A_{n}{{{plus(sh)}v}}: T.{sh.p}_dump(v, t)')
    w('    case A_boxed{v}: dump(v, t)')
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
    w('def fuzz_boxed(pair: Any & Bool) -> Any & Bool:')
    w('  (v, ok) = pair')
    w('  (A_boxed{v}, ok)')
    w('def fuzz(a0: Any, +sel: U32, +a: U32, +b: U32) -> Any & Bool:')
    w('  match a0:')
    L.extend(fz)
    w('    case A_boxed{v}: fuzz_boxed(fuzz(v, sel, a, b))')
    return '\n'.join(L) + '\n'


# the benchmark programs (benchmarks/objprog/): static Bend text, with @K@ (the group) and @MOD@ (the runtime module) filled in
TEMPLATES = ROOT / 'codegen/impl/templates'
PROGRAM = (TEMPLATES / 'objprog.bend.in').read_text()
PROGRAM_FUZZ = (TEMPLATES / 'objprog_fuzz.bend.in').read_text()


def qual(rep):
    """A representation type as seen from the index module."""
    if rep in ('Bool', 'U32') or rep.startswith('O.'):
        return rep
    return 'T.' + rep


GENERIC_GROUP = 8         # generic schemas per generated program


# the monoliths as generated, for the runtime split (codegen/impl/runtime_file_split.py): (text, Gen, names, fork prefix)
SPLIT_CTX = []


def split_contexts():
    """The monoliths' generation contexts (typed_object_runtime.py's own Gen and names), without writing."""
    SPLIT_CTX.clear()
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = Gen()
    text = reorder(emit_all(g, names))
    ctx = [(text, g, names, schema.load_prefix(ROOT / 'codegen/fulu.yaml'))]
    generic_outputs()
    return ctx + list(SPLIT_CTX)


def generic_outputs():
    """The supported generic SSZ forms, generated by the same generator.

    The official `ssz_generic` suite exercises SSZ forms that are not Fulu type
    names (progressive lists and bit lists, progressive containers, compatible
    unions, and containers/vectors/lists over every basic type). They are part
    of the supported public API, so they are generated too, from the frozen
    descriptions in tools/test_schemas.py (codegen/core/generic_form_schemas.py translates them).

    A schema the generator refuses (a zero-length vector, for instance, which
    is not a legal SSZ type) is recorded as unsupported and gets no generated
    code; types/generic_obj_index.json names them, and the official cases for
    them are all invalid cases that must be rejected.
    """
    from codegen.core import generic_form_schemas as gen
    inv, refused = {}, {}
    for n, t, err in gen.inventory_all():
        if err is None:
            inv[n] = t
        else:
            refused[n] = err
    g = Gen()
    names = {}
    for n, t in inv.items():
        try:
            probe = Gen()
            probe.shape(t)
            for s in probe.order:
                emit_shape(s, lambda _x: None)
        except (schema.SchemaError, KeyError, AttributeError, ValueError, IndexError) as exc:
            refused[n] = str(exc) or type(exc).__name__
            continue
        names[n] = t
    text = reorder(emit_all(g, names, title='Typed owning SSZ objects for the supported generic SSZ '
                                            'forms of the official ssz_generic suite', with_fuzz=False))
    out = {}   # the monolith is not written: runtime_file_split splits it (SPLIT_CTX)
    SPLIT_CTX.append((text, g, names, ''))
    order = list(names)
    table = {}
    for k in range(0, len(order), GENERIC_GROUP):
        gn = order[k:k + GENERIC_GROUP]
        j = k // GENERIC_GROUP
        ns = [(n, order.index(n)) for n in gn]
        out[ROOT / f'types/generic_obj_g{j}.bend'] = emit_group(g, names, ns, j, module='generic_obj')
        out[ROOT / f'benchmarks/objprog/x{j}.bend'] = (PROGRAM.replace('@K@', str(j))
                                                       .replace('@MOD@', 'generic_obj'))
        for n, i in ns:
            table[n] = {'group': j, 'index': i}
    out[ROOT / 'types/generic_obj_index.json'] = json.dumps(
        {'generated': table, 'unsupported': refused}, indent=1, sort_keys=True) + '\n'
    return out


def main():
    names = schema.load(ROOT / 'codegen/fulu.yaml')
    g = Gen()
    text = reorder(emit_all(g, names))
    outputs = {}   # the monolith is not written: runtime_file_split splits it
    order = list(names)
    groups = [order[i:i + GROUP_TYPES] for i in range(0, len(order), GROUP_TYPES)]
    table = {}
    for k, gn in enumerate(groups):
        ns = [(n, order.index(n)) for n in gn]
        outputs[ROOT / f'types/fulu_obj_g{k}.bend'] = emit_group(g, names, ns, k)
        outputs[ROOT / f'benchmarks/objprog/g{k}.bend'] = PROGRAM.replace('@K@', str(k)).replace('@MOD@', 'fulu_obj')
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
    SPLIT_CTX.clear()
    outputs.update(generic_outputs())
    # the runtime split, additive stage (codegen/impl/runtime_file_split.py; the monoliths stay the runtime)
    from codegen.impl import runtime_file_split as runtime_file_split
    outputs.update(runtime_file_split.outputs([(text, g, names, schema.load_prefix(ROOT / 'codegen/fulu.yaml'))] + list(SPLIT_CTX)))
    # the group modules import the split files they use (against the index written with them)
    runtime_file_split.use_index(outputs[runtime_file_split.INDEX])
    for p in [p for p in outputs if p.parent == ROOT / 'types' and re.fullmatch(r'(fulu|generic)_obj_[gf]\d+\.bend', p.name)]:
        outputs[p] = runtime_file_split.rewire(outputs[p])
    # the retired monoliths
    retired = [ROOT / 'types/fulu_obj.bend', ROOT / 'types/generic_obj.bend']
    if '--check' in sys.argv:
        stale = [str(p.relative_to(ROOT)) for p, t in outputs.items() if not p.exists() or p.read_text() != t]
        stale += [str(p.relative_to(ROOT)) + ' (retired)' for p in retired if p.exists()]
        if stale:
            print('stale generated sources: ' + ', '.join(stale) + ' (run codegen/impl/typed_object_runtime.py)')
            sys.exit(1)
        print('generated sources are current')
        return
    for p in retired:
        if p.exists():
            p.unlink()
    for p, t in outputs.items():
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(t)
    print(f'the Fulu runtime: {len(g.order)} shapes, {len(names)} names, {len(text.splitlines())} lines; '
          f'{len(groups)} groups of up to {GROUP_TYPES} names')


if __name__ == '__main__':
    main()
