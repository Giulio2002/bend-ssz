#!/usr/bin/env python3
"""A container is valid only if every one of its fields is valid (manual spec-mutation audit: c02/05, c06/03, c06/04, c06/05).

    python3 codegen/proofs/slop/container_field_validity.py [--check]

Public counterexample of the fault: `T.SmallTestStruct_serialize(T.SmallTestStruct{70000, 1})` (the constructor builds the object (the checked
setter `_set_f_A` refuses 70000, its unchecked `_go` body and the constructor do not); a container validity that skips the uint16 check lets the serializer
write 70000 as two bytes). For every container name X with a range-checked scalar field (uint8, uint16: the generic test
structs; the Fulu containers have none) proofs/slop/validity/<runtime>_<X>_fields.bend holds

  <X>_serialize_vfields(f, ...)      only for a container whose validity is a Bool computed from its own fields:
      {T.X_valid(T.X{f_A, ...}) == Bool.and(valid_1(f_1), Bool.and(valid_2(f_2), ...)) : Bool}, symbolic in every field.
      The conjunction is built from the schema (codegen/fulu.yaml, the generic inventory): in field order, `u8_valid` for a
      uint8, `u16_valid` for a uint16; every other fixed field (uint32 and wider, bool, byte vectors) has the constant-True
      validity and adds nothing. The generator stops if the generated encoder spells it differently. A mutant that drops,
      swaps or constant-folds the check of one field changes only the left side.
  <X>_serialize_vreject_<field>()    for each such field: the first out-of-range value makes the container invalid
      {T.X_valid(T.X_set_<field>_go(T.X_default(), 65536)) == False{} : Bool} (a Data container; for a container whose validity
      threads its children, the second component of the pair).

  <X>_serialize_vrefuse_<field>()    the checked serializer refuses that object: `X_serialize(obj) == O.refused()` (the fused poison path).
  <X>_serialize_vpoison_<tag>()      the poison marker itself: pz(False) is poisoned, pz(True) is not, 2^31 - 1 is not, padd carries into bit 31.
  <X>_serialize_vreject_<field>()    (round 2) for every other field kind too, groups included: an out-of-spec Words / Bits / absent Boxed /
      Seq value (tight storage; `_elem`: an absent element; `_earlier`: an invalid element before a valid one) makes the container invalid,
      the others at their default; `vreject_default_valid`: the default object is valid.

They are named so that api_gate files them under serialize_valid (the facade of X's encoder).
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import slop_layout as LAYOUT  # noqa: E402
from codegen.core import fulu_schema_loader as schema  # noqa: E402
from codegen.core import generic_form_schemas as generic  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402
from codegen.impl import runtime_file_split as RR  # noqa: E402
from codegen.proofs.collections.object_field_access_laws import qual  # noqa: E402
from codegen.proofs.slop import encoder_constants as MC  # noqa: E402

RANGE = {1: ('u8_valid', 255), 2: ('u16_valid', 65535)}   # uint size in bytes -> (validity, largest valid value)
CONSTANT_TRUE = ('uint', 'bool', 'bytes')                  # fixed kinds whose validity is True{} (uint size >= 4 here)


def chain(parts):
    """right-nested Bool.and of the conjuncts (True{} for none)"""
    if not parts:
        return 'True{}'
    return parts[0] if len(parts) == 1 else f'Bool.and({parts[0]}, {chain(parts[1:])})'


def ranged(t):
    """[(field, validity, first bad value)] of the range-checked scalar fields of container type t, in order"""
    return [(fn, RANGE[ft.size][0], RANGE[ft.size][1] + 1) for fn, ft in t.fields if ft.kind == 'uint' and ft.size in RANGE]


def expected_conjunction(t):
    """the schema's validity of a fixed container, or None when a field's validity is not one of the known ones"""
    parts = []
    for fn, ft in t.fields:
        if ft.kind == 'uint' and ft.size in RANGE:
            parts.append(f'{RANGE[ft.size][0]}({fn})')
        elif ft.kind == 'bool' or (ft.kind in ('uint', 'bytes') and ft.fixed()):
            continue
        else:
            return None
    return chain(parts)


def laws_of(tx, X, t):
    rng = ranged(t)
    v = tx.get(f'{X}_valid')
    rep = v[1].split(' & ')[0] if v and ' & ' in v[1] else None     # pair-valued: `X & Bool`
    laws = []
    body = re.search(rf'^def {re.escape(X)}_valid\(\+?o: [\w.]+\) -> Bool:\n  match o:\n    case \w+\{{([^}}]*)\}}: (.*)$', tx.text, re.M)
    if body:
        want = expected_conjunction(t)
        got = body.group(2)
        if want is None or want != got:
            raise SystemExit(f'{X}: the encoder validity `{got}` is not the schema conjunction `{want}`')
        decl = re.search(rf'^type {re.escape(X)} is Data:\n  \w+\{{(.*)\}}$', tx.text, re.M)
        fields = [(a.split(':', 1)[0].strip(), a.split(':', 1)[1].strip()) for a in MC.split_top_args(decl.group(1))]
        params = ', '.join(f'{"+" if ty == "U32" else ""}{n}: {qual(ty)}' for n, ty in fields)
        rhs = re.sub(r'(?<![\w.])(\w+_valid)\(', r'T.\1(', want)
        laws.append(f'def {X}_serialize_vfields({params})\n    -> {{T.{X}_valid(T.{X}{{{", ".join(n for n, _ in fields)}}}) == {rhs} : Bool}}:\n  {{==}}')
    if rng and tx.get(f'{X}_serialize'):
        # the poison marker of the fused check: a false flag is the marker 4294967295, a true one is 0, and the test reads a size above NMAX = 4294967264 (at 4294967265 too)
        for tag, stmt in (('false_flag', 'O.is_poisoned(O.pz(False{})) == True{}'), ('true_flag', 'O.is_poisoned(O.pz(True{})) == False{}'),
                          ('below', 'O.is_poisoned(4294967264) == False{}'), ('carried', 'O.is_poisoned(O.padd(5, 4294967295)) == True{}')):
            laws.append(f'def {X}_serialize_vpoison_{tag}()\n    -> {{{stmt} : Bool}}:\n  {{==}}')
    for fn, _, bad in rng:
        obj = f'T.{X}_set_{fn}_go(T.{X}_default(), {bad})'
        stmt = f'Pair.snd({qual(rep)}, Bool, T.{X}_valid({obj}))' if rep else f'T.{X}_valid({obj})'
        laws.append(f'def {X}_serialize_vreject_{fn}()\n    -> {{{stmt} == False{{}} : Bool}}:\n  {{==}}')
        # the checked serializer refuses it: the fused poison path (O.pz / O.padd / O.is_poisoned) carries the verdict
        ser = tx.get(f'{X}_serialize')
        if ser:
            sstmt = (f'Pair.snd({qual(rep)}, O.Encoded, T.{X}_serialize({obj})) == O.refused() : O.Encoded' if rep
                     else f'T.{X}_serialize({obj}) == O.refused() : O.Encoded')
            laws.append(f'def {X}_serialize_vrefuse_{fn}()\n    -> {{{sstmt}}}:\n  {{==}}')
    return laws


SERIALIZE_MAX = 3000        # bytes: the checked serializer of a bigger default object is not run by a law (a sidecar's blob, a state)
TIGHT_WORDS = 'O.Words{Array.new(U32, 0n, 0), 5}'      # 5 bytes on a one-word storage: the check wants two words
TIGHT_BITS = 'O.Bits{Array.new(U32, 0n, 0), 64}'       # 64 bits on a one-word storage: the check wants three words


def type_decls(tx):
    """{type name: [(field, type text)]} of the single-constructor types of the runtime text"""
    out = {}
    for m in re.finditer(r'^type (\w+) is (?:Data|Type):\n  \w+\{([^\n]*)\}$', tx.text, re.M):
        out[m.group(1)] = [(a.split(':', 1)[0].strip(), a.split(':', 1)[1].strip()) for a in MC.split_top_args(m.group(2))] if m.group(2) else []
    return out


def bad_values(tx, decls, ty):
    """[(tag, value)]: invalid values of the field type `ty` that cost nothing to build (none when its validity is True{})"""
    if ty == 'O.Words':
        return [('', TIGHT_WORDS)]
    if ty == 'O.Bits':
        return [('', TIGHT_BITS)]
    if ty.startswith('O.Boxed<'):
        return [('', 'O.BNone{}')]
    if ty.endswith('_Seq') and ty in decls:
        fill = ty[:-len('_Seq')] + '_fill'
        if fill not in tx.blk:
            return []
        out = [('', f'T.{ty}{{T.{fill}(0n), 2}}')]           # 2 elements on a storage of one slot
        if re.fullmatch(r'Array<O\.Boxed<.*>>', decls[ty][0][1]):
            out.append(('_elem', f'T.{ty}{{T.{fill}(0n), 1}}'))   # the one slot holds the absent (invalid) box
            if decls[ty][0][1] == 'Array<O.Boxed<O.Words>>':
                # an invalid element followed by a valid one: the running conjunction must keep the first verdict
                out.append(('_earlier', f'T.{ty}{{Array.set(O.Boxed<O.Words>, T.{fill}(1n), 1, O.BSome{{O.words_new(0), O.BNone{{}}}}), 2}}'))
        lim = re.search(r'Bool\.or\((True|False)\{\}, U32\.is_le\(n, (\d+)\)\)', tx.blk.get(ty[:-len('_Seq')] + '_valid', ''))
        if lim and lim.group(1) == 'False' and int(lim.group(2)) < (1 << 20):
            # one element past the limit on a storage that holds it: only the limit refuses it (round 3: l01/10)
            out.append(('_limit', f'T.{ty}{{T.{fill}({int(lim.group(2)).bit_length()}n), {int(lim.group(2)) + 1}}}'))
        return out
    return []


def witness_laws(tx, X, fu_t):
    """one law per field (inside a group too) whose validity has a cheap invalid value: the container built from the default object
    with that field replaced is invalid; `X_valid` is the whole container's pass (Bool or the threading pair)"""
    decls = type_decls(tx)
    small = MC.min_size(fu_t) <= SERIALIZE_MAX     # the serializer writes the whole object: not the 130 KB blob of a sidecar, not a state
    if X not in decls:
        return []
    v = tx.get(f'{X}_valid')
    rep = v[1].split(' & ')[0] if v and ' & ' in v[1] else None
    laws = []

    def law(tag, obj, refuse=False):
        stmt = f'Pair.snd({qual(rep)}, Bool, T.{X}_valid({obj}))' if rep else f'T.{X}_valid({obj})'
        laws.append(f'def {X}_serialize_vreject_{tag}()\n    -> {{{stmt} == False{{}} : Bool}}:\n  {{==}}')
        if refuse and small and tx.get(f'{X}_serialize'):
            # the checked serializer refuses it (an absent box: CH-12, the writer's poison flag; an invalid child: the size pass's)
            sstmt = (f'Pair.snd({qual(rep)}, O.Encoded, T.{X}_serialize({obj})) == O.refused() : O.Encoded' if rep
                     else f'T.{X}_serialize({obj}) == O.refused() : O.Encoded')
            laws.append(f'def {X}_serialize_vrefuse_{tag}()\n    -> {{{sstmt}}}:\n  {{==}}')
    if tx.get(f'{X}_default') and v:
        # the default object is a valid object (its fixed-length vectors of variable elements hold present, valid elements)
        stmt = f'Pair.snd({qual(rep)}, Bool, T.{X}_valid(T.{X}_default()))' if rep else f'T.{X}_valid(T.{X}_default())'
        laws.append(f'def {X}_serialize_vreject_default_valid()\n    -> {{{stmt} == True{{}} : Bool}}:\n  {{==}}')
    go, sized = tx.blk.get(f'{X}_senc_go'), tx.blk.get(f'{X}_senc_sized')
    if go and sized and tx.get(f'{X}_default'):
        # the refusal of a poisoned size comes before the allocation of its output (CH-02): the first test of serialize, on its own
        pair = ' & O.Encoded' in go.split('\n', 1)[0]
        snd = (lambda c: f'Pair.snd({qual(X)}, O.Encoded, {c})') if pair else (lambda c: c)    # noqa: E731
        laws.append(f'def {X}_serialize_vrefuse_bad_flag()\n    -> {{{snd(f"T.{X}_senc_go(True{{}}, 0, T.{X}_default())")} == O.refused() : O.Encoded}}:\n  {{==}}')
        laws.append(f'def {X}_serialize_vrefuse_poisoned_size()\n    -> {{{snd(f"T.{X}_senc_sized((T.{X}_default(), 4294967295))")} == O.refused() : O.Encoded}}:\n  {{==}}')
    for fn, ty in decls[X]:
        if ty.startswith(f'{X}_g') and ty in decls:         # a group of fields: its own setters, the others at their default
            for gf, gty in decls[ty]:
                for sfx, bad in bad_values(tx, decls, gty):
                    if f'{ty}_set_{gf}' in tx.blk:
                        comps = ', '.join(f'T.{ty}_set_{gf}(T.{ty}_default(), {bad})' if n == fn else f'T.{t2}_default()' for n, t2 in decls[X])
                        law(gf + sfx, f'T.{X}{{{comps}}}', refuse=bad == 'O.BNone{}' or sfx == '_limit')
        else:
            for sfx, bad in bad_values(tx, decls, ty):
                if f'{X}_set_{fn}' in tx.blk:
                    law(fn + sfx, f'T.{X}_set_{fn}(T.{X}_default(), {bad})', refuse=bad == 'O.BNone{}' or sfx == '_limit')
            mb = re.fullmatch(r'O\.Boxed<(\w+)>', ty)
            if mb and mb.group(1) in decls and f'{X}_set_{fn}' in tx.blk and f'{mb.group(1)}_bx_wrap' in tx.blk:
                # a present box whose value is invalid: the first field of the child that has a cheap invalid value
                Y = mb.group(1)
                inner = [(gf, sfx, bad) for gf, gty in decls[Y] for sfx, bad in bad_values(tx, decls, gty)[:1] if f'{Y}_set_{gf}' in tx.blk]
                if inner:
                    gf, sfx, bad = inner[0]
                    law(f'{fn}_{gf}{sfx}', f'T.{X}_set_{fn}(T.{X}_default(), T.{Y}_bx_wrap(T.{Y}_set_{gf}(T.{Y}_default(), {bad})))', refuse=True)
    return laws


def box_laws(tx, X, t):
    """the laws of the box of X (CH-12: an absent box stays absent through every pass): size pass, validity pass, checked writer and the writer of a present box"""
    if t.fixed() or f'{X}_bx_size' not in tx.blk or f'{X}_bx_wrap' not in tx.blk or not tx.get(f'{X}_serialize'):
        return []
    B = f'O.Boxed<T.{X}>'
    out = [f'def {X}_serialize_vreject_bx_size()\n    -> {{T.{X}_bx_size(O.BNone{{}}) == (O.BNone{{}}, 0) : {B} & U32}}:\n  {{==}}',
           f'def {X}_serialize_vreject_bx_valid()\n    -> {{T.{X}_bx_valid(O.BNone{{}}) == (O.BNone{{}}, False{{}}) : {B} & Bool}}:\n  {{==}}']
    if f'{X}_bx_putk' in tx.blk and MC.min_size(t) <= SERIALIZE_MAX:
        out.append(f'def {X}_serialize_vpoison_bx_absent()\n    -> {{Pair.snd({B}, U32, Pair.snd(Array<U32>, {B} & U32, T.{X}_bx_putk(Array.new(U32, 1n, 0), 0, O.BNone{{}}))) == 4294967295 : U32}}:\n  {{==}}')
        # a present box holds the verdict of its value: the box of an invalid X is poisoned (the writer's flag), the box of the default is not
        decls = type_decls(tx)
        bad = [(fn, b) for fn, ty in decls.get(X, []) for _, b in bad_values(tx, decls, ty)[:1] if f'{X}_set_{fn}' in tx.blk]
        put = lambda obj: f'Pair.snd({B}, U32, Pair.snd(Array<U32>, {B} & U32, T.{X}_bx_putk(Array.new(U32, 4n, 0), 0, T.{X}_bx_wrap({obj}))))'    # noqa: E731
        out.append(f'def {X}_serialize_vpoison_bx_ok()\n    -> {{O.is_poisoned({put(f"T.{X}_default()")}) == False{{}} : Bool}}:\n  {{==}}')
        if bad:
            fn, b = bad[0]
            out.append(f'def {X}_serialize_vpoison_bx_invalid()\n    -> {{O.is_poisoned({put(f"T.{X}_set_{fn}(T.{X}_default(), {b})")}) == True{{}} : Bool}}:\n  {{==}}')
    return out


def union_laws(tx, X, t):
    """a union is valid only if the payload of its arm is valid (round 3: u01/08): per arm, the first field of the payload with a cheap invalid value"""
    decls = type_decls(tx)
    small = MC.min_size(t) <= SERIALIZE_MAX     # the serializer writes the whole object: not the 130 KB blob of a sidecar, not a state
    v = tx.get(f'{X}_valid')
    rep = v[1].split(' & ')[0] if v and ' & ' in v[1] else None
    laws = []
    for i, Y in re.findall(rf'^  {re.escape(X)}_c(\d+)\{{v: (\w+)\}}', tx.text, re.M):
        bad = [(fn, b) for fn, ty in decls.get(Y, []) for _, b in bad_values(tx, decls, ty)[:1] if f'{Y}_set_{fn}' in tx.blk]
        if not bad or not v:
            continue
        fn, b = bad[0]
        obj = f'T.{X}_c{i}{{T.{Y}_set_{fn}(T.{Y}_default(), {b})}}'
        stmt = f'Pair.snd({qual(rep)}, Bool, T.{X}_valid({obj}))' if rep else f'T.{X}_valid({obj})'
        laws.append(f'def {X}_serialize_vreject_c{i}_{fn}()\n    -> {{{stmt} == False{{}} : Bool}}:\n  {{==}}')
        if small and tx.get(f'{X}_serialize'):
            sstmt = (f'Pair.snd({qual(rep)}, O.Encoded, T.{X}_serialize({obj})) == O.refused() : O.Encoded' if rep
                     else f'T.{X}_serialize({obj}) == O.refused() : O.Encoded')
            laws.append(f'def {X}_serialize_vrefuse_c{i}_{fn}()\n    -> {{{sstmt}}}:\n  {{==}}')
    return laws


def module(tmod, laws, X):
    L = ['import Base', 'import ../../src/obj.bend as O', f'import ../../types/{tmod}.bend as T', '',
         writer.header('container_field_validity'),
         f'# {X}: a container is valid only if every field is valid (manual spec-mutation audit; docs/mutation_testing/MUTATION_PROOFS.md).', '']
    for t in laws:
        L += [t, '']
    return '\n'.join(L)


def outputs():
    out = {}
    fu = schema.load(ROOT / 'codegen/fulu.yaml')
    gen = {n: t for n, t, e in generic.inventory_all() if e is None}
    for runtime, tmod, names in (('fulu', 'fulu_obj', fu), ('generic', 'generic_obj', gen)):
        tx = MC.Text(runtime)
        for X, t in names.items():
            if t.kind == 'cunion':
                laws = union_laws(tx, X, t)
                if laws:
                    out[LAYOUT.module_path('validity', f'{runtime}_{X}_fields')] = module(tmod, laws, X)
                continue
            if t.kind not in ('container', 'pcontainer'):
                continue
            laws = laws_of(tx, X, t) + witness_laws(tx, X, t) + box_laws(tx, X, t)
            if laws:
                out[LAYOUT.module_path('validity', f'{runtime}_{X}_fields')] = module(tmod, laws, X)
    return out


def main():
    out = outputs()
    if LAYOUT.finish(RR.rewire_out(out), 'container_field_validity', ('validity',), 'stale container field validity laws: ',
                     'container field validity laws are current', '--check' in sys.argv):
        print(f'{len(out)} modules')


if __name__ == '__main__':
    main()
