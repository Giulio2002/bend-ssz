#!/usr/bin/env python3
"""More laws that pin constants of the frozen spec no other law reaches (docs/mutation_testing/MUTATION_PROOFS.md section 8): the spec is
never edited; each law states a spec function on witnesses in a small module that imports the spec file.

    python3 codegen/proofs/mutation_coverage/spec_constants_extra.py [--check]

  spec/bit_root.bend chunk_limit(1n) == 1n, chunk_limit(257n) == 2n              (ceil(N / 256): the 255n)
  spec/packing.bend pack of 33 bytes is two chunks, the first of 32 bytes        (the room 31n of scan)
  spec/tree.bend capacity(0n) == 1n, capacity(3n) == 8n                       (a depth-0 tree holds one leaf)
  spec/type_legality.bend inhabitants of type_legal for a union of 1 option behind Null, of 127 options behind Null and
                         of 127 options (a type error when the field-count bounds 0n / 127n move)
  spec/fulu_schemas.bend Schema52() is Vector[Schema8(), SYNC_COMMITTEE_SIZE] (the value is read from codegen/fulu.yaml)
  spec/root_relation.bend aggregate(True, a, ..) == aggregate(True, b, ..): the limit of a progressive sequence is unread (the 0n of
                         `sequence(.., 0n, True{}, ..)` is equivalent: no statement can depend on it)
  spec/representation.bend erase puts the placeholder length 0n in every erased type, whatever the length it replaces
                         (the placeholder is irrelevant to `shape`, proofs/representation_erasure.bend: shape(v, s) ==
                         shape(v, erase(s)); the pins make the chosen placeholder explicit)
"""
import sys as _sys
import pathlib as _pathlib
_sys.path.insert(0, str(_pathlib.Path(__file__).resolve().parents[3]))  # the repository root: `codegen` is importable when this file runs as a script
import re
import sys

from codegen.core import generated_file_writer as writer  # noqa: E402
from codegen.core import mutation_layout as LAYOUT  # noqa: E402
from codegen.core.repository_paths import ROOT  # noqa: E402

H = writer.header("spec_constants_extra")


def mod(imports, body):
    if any(a == "S" for a, _ in imports):    # the legality module's proofs of impossibility use the logic lemmas
        imports = imports + [("FD", "proofs/compact/found.bend")]
    return "import Base\n" + "".join(f"import ../../{p} as {a}\n" for a, p in imports) + H + "\n" + body


def law(name, params, stmt):
    return f"def {name}({params}) -> {{{stmt}}}:\n  {{==}}\n"


def legality():
    # ch(k): a chain of k booleans; pr(k): the inhabitant of legal(ch(k), True) =
    # {forest == True} & legal(Boolean, False) & legal(rest, True), right-nested pairs
    return (
        "def ch(+k: Nat) -> T.Schema:\n  match k:\n    case 0n: T.End{}\n    case 1n+p: T.Chain{T.Boolean{}, ch(p)}\n"
        "def pr(+k: Nat) -> S.legal(ch(k), True{}):\n  match k:\n    case 0n: {==}\n    case 1n+p: ({==}, ({==}, pr(p)))\n"
        # Union{Chain{Null, rest}}: {forest} & {0 < n} & {n <= 127} & legal(rest, True)
        "def union_null_1() -> S.type_legal(T.Union{T.Chain{T.Null{}, ch(1n)}}):\n  ({==}, ({==}, ({==}, pr(1n))))\n"
        "def union_null_127() -> S.type_legal(T.Union{T.Chain{T.Null{}, ch(127n)}}):\n  ({==}, ({==}, ({==}, pr(127n))))\n"
        # Union{Chain{head, rest}}: {forest} & {n <= 127} & legal(head, False) & legal(rest, True)
        "def bitvector_1() -> S.type_legal(T.BitVector{1n}):\n  ({==}, {==})\n"
        "def bytevector_1() -> S.type_legal(T.ByteVector{1n}):\n  ({==}, {==})\n"
        "def vector_1() -> S.type_legal(T.Vector{T.Boolean{}, 1n}):\n  ({==}, ({==}, {==}))\n"
        # CompatibleUnion{[1], Chain{Boolean, End}}: {forest} & {0 < n} & {len ids == n} & selectors(ids) & legal(options, True) &
        # mutually_compatible(options) (a derivation Fork{Fork{Leaf, Leaf}, Leaf} of All{} options options)
        "def compatible_union_1() -> S.type_legal(T.CompatibleUnion{[1], ch(1n)}):\n"
        "  ({==}, ({==}, ({==}, (({==}, ({==}, ({==}, Unit{}))), (pr(1n), (C.Fork{C.Fork{C.Leaf{}, C.Leaf{}}, C.Leaf{}}, {==}))))))\n"
        "def union_127() -> S.type_legal(T.Union{T.Chain{T.Boolean{}, ch(127n)}}):\n  ({==}, ({==}, ({==}, pr(127n))))\n"
        # 128 options are illegal: the bound component {128 <= 127 == True} is {False == True}
        "def union_null_128(h: S.type_legal(T.Union{T.Chain{T.Null{}, ch(128n)}})) -> Empty:\n"
        "  match h:\n    case (a, b):\n      match b:\n        case (c, d):\n          match d:\n            case (e, f): FD.logic__false_true(e)\n"
        "def union_128(h: S.type_legal(T.Union{T.Chain{T.Boolean{}, ch(128n)}})) -> Empty:\n"
        "  match h:\n    case (a, b):\n      match b:\n        case (c, d): FD.logic__false_true(c)\n")


def chunks_bits():
    """chunks of 257 bits (a 1 in the last): two 32-byte chunks, the second [1, 0 ...]; and of 8 bits, one chunk"""
    lit = lambda a: "[" + ", ".join(map(str, a)) + "]"   # noqa: E731
    bl = lambda a: "[" + ", ".join("True{}" if b else "False{}" for b in a) + "]"   # noqa: E731
    bits = [0] * 256 + [1]
    return (law("chunks_257", "", f"K.chunks({bl(bits)}) == [{lit([0] * 32)}, {lit([1] + [0] * 31)}] : +List<+List<U32>>")
            + law("chunk_limit_0", "", "K.chunk_limit(0n) == 0n : Nat") + law("chunk_limit_256", "", "K.chunk_limit(256n) == 1n : Nat")
            + law("chunk_limit_512", "", "K.chunk_limit(512n) == 2n : Nat") + law("chunk_limit_513", "", "K.chunk_limit(513n) == 3n : Nat"))


def packing():
    xs = list(range(33))
    lit = lambda a: "[" + ", ".join(map(str, a)) + "]"   # noqa: E731
    return law("pack_33", "", f"Pack.pack({lit(xs)}) == Some{{[{lit(xs[:32])}, {lit(xs[32:] + [0] * 31)}]}} : Maybe<&2, +List<+List<U32>>>")


def representation():
    out = []
    for i, (c, args, res) in enumerate([("ByteVector", "n", "T.ByteVector{0n}"), ("ByteList", "n", "T.ByteVector{0n}"),
                                       ("BitVector", "n", "T.BitVector{0n}"), ("BitList", "n", "T.BitVector{0n}"),
                                       ("ProgressiveBits", "", "T.BitVector{0n}")]):
        p = "n: Nat" if args else ""
        out.append(law(f"erase_{c}", p, f"S.erase(T.{c}{{{args}}}) == {res} : T.Schema"))
    for c in ("Vector", "ListOf"):
        out.append(law(f"erase_{c}", "e: T.Schema, n: Nat", f"S.erase(T.{c}{{e, n}}) == T.Vector{{S.erase(e), 0n}} : T.Schema"))
    out.append(law("erase_ProgressiveList", "e: T.Schema", "S.erase(T.ProgressiveList{e}) == T.Vector{S.erase(e), 0n} : T.Schema"))
    return "".join(out)


Z32 = "[" + ", ".join(["0"] * 32) + "]"


def root_relation_extra():
    """count (the container limit), the Null leaf, and the progressive-limit independence of the two sites of roots that spell the 0n"""
    return (law("count_end", "", "R.count(T.End{}) == 0n : Nat")
            + law("count_two", "", "R.count(T.Chain{T.Boolean{}, T.Chain{T.Boolean{}, T.End{}}}) == 2n : Nat")
            + law("root_null", "", f"R.roots(T.NullValue{{}}, T.Null{{}}, [{Z32}]) == {{[{Z32}] == [{Z32}] : +List<+List<U32>>}} : Type")
            # roots at ProgressiveBits / ProgressiveList is aggregate / sequence at ANY limit (the site's 0n is irrelevant: equivalent)
            + law("roots_progressive_bits_any_limit", "+a: Nat, +bits: +List<Bool>, +o: +List<+List<U32>>",
                  "R.roots(T.BitsValue{bits}, T.ProgressiveBits{}, o) == R.aggregate(True{}, a, Bits.chunks(bits), Some{List.length(&2, Bool, bits)}, o) : Type")
            + law("roots_progressive_list_any_limit", "+a: Nat, +items: T.Value, +s: T.Schema, +o: +List<+List<U32>>",
                  "R.roots(T.Sequence{items}, T.ProgressiveList{s}, o) == R.sequence(R.basic_size(s), R.basic_bytes(items, s), chunks => R.roots(items, T.Repeat{s}, chunks), a, True{}, Some{Codec.count(items)}, o) : Type"))


def serializable_extra():
    return (law("roots_progressive_bits_any_limit", "+a: Nat, +bits: +List<Bool>, +o: +List<+List<U32>>",
                "Z.roots(T.BitsValue{bits}, T.ProgressiveBits{}, o) == R.aggregate(True{}, a, Bits.chunks(bits), Some{List.length(&2, Bool, bits)}, o) : Type")
            + law("roots_progressive_list_any_limit", "+a: Nat, +items: T.Value, +s: T.Schema, +o: +List<+List<U32>>",
                  "Z.roots(T.Sequence{items}, T.ProgressiveList{s}, o) == R.sequence(R.basic_size(s), Codec.encoding_for_legal_type(T.ProgressiveList{s}, T.Sequence{items}), chunks => Z.roots(items, T.Repeat{s}, chunks), a, True{}, Some{Codec.count(items)}, o) : Type"))


def schema_pins():
    """One law per definition of spec/fulu_schemas.bend: `X() == <its text>`. Every size, index and field name of every schema is then
    a constant the module states again, so a changed constant in the spec (a copy of it, in a mutation run) is a statement mismatch.
    The text is read from the spec file when the generator runs; the spec itself is never edited."""
    out = []
    for m in re.finditer(r"^def (\w+)\(\) -> T\.Schema: (.*)$", (ROOT / "spec/fulu_schemas.bend").read_text(), re.M):
        body = re.sub(r"(?<![\w.])(Schema\d+|[A-Z]\w*)\(\)", r"F.\1()", m.group(2))
        out.append(law(f"pin_{m.group(1)}", "", f"F.{m.group(1)}() == {body} : T.Schema"))
    return "".join(out)


def sync_size():
    y = (ROOT / "codegen/fulu.yaml").read_text()
    return int(re.search(r"^\s*SYNC_COMMITTEE_SIZE:\s*(\d+)", y, re.M).group(1))


def outputs():
    S = [("T", "types/schema.bend")]
    o = {
        "bit_root": mod([("K", "spec/bit_root.bend")],
                        law("chunk_limit_1", "", "K.chunk_limit(1n) == 1n : Nat") + law("chunk_limit_257", "", "K.chunk_limit(257n) == 2n : Nat")
                        + chunks_bits()),
        "packing": mod([("Pack", "spec/packing.bend")], packing()),
        "tree": mod([("K", "spec/tree.bend"), ("P", "spec/primitives.bend"), ("M", "spec/merkle.bend")],
                    law("capacity_0", "", "K.capacity(0n) == 1n : Nat") + law("capacity_3", "", "K.capacity(3n) == 8n : Nat")
                    + law("tree_empty_0", "", "K.tree(0n, []) == P.zero_bytes(32n) : +List<U32>")
                    # the empty tree of depth 1 + p is the zero subtree of depth 1 + p (symbolic in p: no hash is computed)
                    + law("tree_empty_succ", "+p: Nat", "K.tree(1n+p, []) == M.zero_subtree(1n+p) : +List<U32>")),
        "type_legality": mod(S + [("S", "spec/type_legality.bend"), ("C", "spec/compatibility.bend")], legality()),
        "fulu_schemas": mod(S + [("F", "spec/fulu_schemas.bend"), ("P", "types/primitive.bend")],
                            law("schema52", "", f"F.Schema52() == T.Vector{{F.Schema8(), {sync_size()}n}} : T.Schema") + schema_pins()),
        "root_relation": mod([("R", "spec/root_relation.bend"), ("T", "types/schema.bend"), ("Codec", "spec/codec.bend"), ("Bits", "spec/bit_root.bend")],
                             law("aggregate_progressive_ignores_limit", "+a: Nat, +b: Nat, +c: +List<+List<U32>>, +l: Maybe<&2, Nat>, +o: +List<+List<U32>>",
                                 "R.aggregate(True{}, a, c, l, o) == R.aggregate(True{}, b, c, l, o) : Type")
                             + law("sequence_progressive_ignores_limit",
                                   "s: Maybe<&2, Nat>, e: Maybe<&2, +List<U32>>, k: +List<+List<U32>> -> Type, +a: Nat, +b: Nat, +l: Maybe<&2, Nat>, +o: +List<+List<U32>>",
                                   "R.sequence(s, e, k, a, True{}, l, o) == R.sequence(s, e, k, b, True{}, l, o) : Type")
                             + root_relation_extra()),
        "root_relation_serializable": mod([("R", "spec/root_relation.bend"), ("Z", "spec/root_relation_serializable.bend"), ("T", "types/schema.bend"),
                                           ("Codec", "spec/codec.bend"), ("Bits", "spec/bit_root.bend")], serializable_extra()),
        "representation": mod(S + [("S", "spec/representation.bend")], representation()),
    }
    return {LAYOUT.module_path("spec", k): v for k, v in o.items()}


def main():
    out = outputs()
    LAYOUT.check_or_write(out, "stale spec constant laws: ", "spec constant laws are current", "--check" in sys.argv)
    if "--check" not in sys.argv:
        print(f"{len(out)} modules")


if __name__ == "__main__":
    main()
